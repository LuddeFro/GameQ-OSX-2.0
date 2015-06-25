//
//  DotaReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:GameDetector, PacketDetector{
    
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    static var packetParser:PacketParser = PacketParser.getSharedInstance()
    
    static let dotaFilter:String = "udp src portrange 27000-28999 or udp dst portrange 27000-28999"
    static let portMin:Int = 27000
    static let portMax:Int = 27050
    
    static var queuePort:Int = -1
    static var srcQueueTimer:[PacketTimer] = [PacketTimer]()
    static var srcQueueCounter:[Int:Int] = [78:0, 158:0, 270:0, 285:0]
    
    static var dstQueueTimer:[PacketTimer] = [PacketTimer]()
    static var dstQueueCounter:[Int:Int] = [126:0, 142:0, 174:0, 222:0]
    
    static var stopQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopQueueCounter:[Int:Int] = [78: 0, 250:0]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
    
    static var gameTimerLate:[PacketTimer] = [PacketTimer]()
    static var packetCounterLate:[Int:Int] = [164:0, 174:0, 190:0, 206:0]
    
    static var dstGameTimer:[PacketTimer] = [PacketTimer]()
    static var dstPacketCounter:[Int:Int] = [78:0]
    
    static var isProbablyGame:Bool = false
    static var inGameTimer:[PacketTimer] = [PacketTimer]()
    static let inGameMaxSize:Int = 70
    static var inGamePacketCounter:[Int:Int] = [Int:Int]()
    
    static var saveCounter = 0;
    
    override class func startDetection() {
        self.game = Game.Dota
        self.detector = self
        self.countDownLength = 45
        updateStatus(Status.InLobby)
        super.startDetection()
        
        if(!isCapturing){
            dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
                self.packetParser.start_loop(self.dotaFilter, detector: self
                )})}
        isCapturing = true
    }
    
    override class func resetDetection(){
        super.resetDetection()
        resetQueueTimer()
        resetGameTimer()
        resetInGameTimer()
        saveCounter = 0
    }
    
    
    override class func saveDetection(){
        super.saveDetection()
        dataHandler.logPackets(packetQueue)
    }
    
    override class func saveMissedDetection(){
        super.saveMissedDetection()
        dataHandler.logPackets(packetQueue)
    }
    
    override class func stopDetection(){
        if(isCapturing){
            packetParser.stop_loop()
            isCapturing = false
        }
        resetDetection()
        super.stopDetection()
    }
    
    class func resetQueueTimer(){
        srcQueueTimer = [PacketTimer]()
        srcQueueCounter = [78:0, 158:0, 270:0, 285:0]
        queuePort = -1
        stopQueueTimer = [PacketTimer]()
        stopQueueCounter = [78: 0, 250:0, 1300: 0]
        dstQueueTimer = [PacketTimer]()
        dstQueueCounter = [78:0, 126:0, 142:0, 174:0, 270:0, 285:0]
    }
    
    class func resetGameTimer(){
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
        
        gameTimerLate = [PacketTimer]()
        packetCounterLate = [164:0, 174:0, 190:0, 206:0]
        
        dstGameTimer = [PacketTimer]()
        dstPacketCounter = [78:0]
        
        isProbablyGame = false
    }
    
    class func resetInGameTimer(){
        inGameTimer = [PacketTimer]()
        inGamePacketCounter = [Int:Int]()
    }
    
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int){
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        update(newPacket);
    }
    
    class func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double) {
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen, time: time)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        update(newPacket);
    }
    
    
    class func update(newPacket: Packet){
        
        packetQueue.insert(newPacket, atIndex: 0)
        if packetQueue.count >= queueMaxSize {
            packetQueue.removeLast()
        }
        
        
        //IN LOBBY
        if(status == Status.InLobby){
            
            var inGame:Bool = isInGame(newPacket, timeSpan: 5, packetNumber: 30)
            var gameReady:Bool = isGameReady(newPacket)
            var startedQueueing:Bool = queueStarted(newPacket, timeSpan: 30, maxPacket:5, packetNumber: 2)
            
            if(inGame){updateStatus(Status.InGame)}
            else if(gameReady){updateStatus(Status.GameReady)}
            else if(startedQueueing){updateStatus(Status.InQueue)}
        }
            
            //IN QUEUE
        else  if(status == Status.InQueue){
            var inGame:Bool = isInGame(newPacket, timeSpan: 5, packetNumber: 30)
            var gameReady:Bool = isGameReady(newPacket)
            var stillQueueing:Bool = isStillQueueing(newPacket, timeSpan: 30, maxPacket: 5, packetNumber: 2)
            
            if(inGame){updateStatus(Status.InGame)}
            else if(gameReady){updateStatus(Status.GameReady)}
            else if(!stillQueueing){updateStatus(Status.InLobby)
                resetQueueTimer()
            }
        }
            
            //GAME READY
        else if(status == Status.GameReady){
            var inGame:Bool = isInGame(newPacket, timeSpan: 6, packetNumber: 30)
            resetGameTimer()
            
            if(inGame){updateStatus(Status.InGame)
                resetQueueTimer()}
        }
            
            //IN GAME
        else  if(status == Status.InGame){
            var inGame:Bool = isInGame(newPacket, timeSpan: 6, packetNumber: 30)
            
            if(!inGame){updateStatus(Status.InLobby)
                resetQueueTimer()
                resetInGameTimer()
            }
        }
            
        else {
            
        }
    }
    
    class func queueStarted(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!srcQueueTimer.isEmpty && p.captureTime - srcQueueTimer.last!.time > timeSpan){
            var key:Int = srcQueueTimer.removeLast().key
            srcQueueCounter[key]! = srcQueueCounter[key]! - 1
        }
        
        while(!dstQueueTimer.isEmpty && p.captureTime - dstQueueTimer.last!.time > timeSpan){
            var key:Int = dstQueueTimer.removeLast().key
            dstQueueCounter[key]! = dstQueueCounter[key]! - 1
        }
        
        for key in srcQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.srcPort <= portMax && p.srcPort >= portMin){
                    srcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    srcQueueCounter[key]! = srcQueueCounter[key]! + 1
            }
        }
        
        for key in dstQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.dstPort <= portMax && p.dstPort >= portMin){
                    dstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    dstQueueCounter[key]! = dstQueueCounter[key]! + 1
            }
        }
        
        //    println(srcQueueCounter)
        //    println(dstQueueCounter)
        if(srcQueueCounter[78] > 0 && srcQueueCounter[158] > 0
            || (dstQueueCounter[174] > 0 && srcQueueCounter[78] > 0 && (srcQueueCounter[270] > 0 || srcQueueCounter[285] > 0 )))
        {
            queuePort = p.srcPort
            
            srcQueueTimer.insert(PacketTimer(key: 158, time: p.captureTime),atIndex: 0)
            var oldCount1:Int = srcQueueCounter[158]!
            srcQueueCounter.updateValue(oldCount1 + 1, forKey: 158)
            
            srcQueueTimer.insert(PacketTimer(key: 78, time: p.captureTime),atIndex: 0)
            var oldCount2:Int = srcQueueCounter[78]!
            srcQueueCounter.updateValue(oldCount2 + 1, forKey: 78)
            
            dstQueueTimer.insert(PacketTimer(key: 126, time: p.captureTime),atIndex: 0)
            var oldCount3:Int = dstQueueCounter[126]!
            dstQueueCounter.updateValue(oldCount3 + 1, forKey: 126)
            
            dstQueueTimer.insert(PacketTimer(key: 142, time: p.captureTime),atIndex: 0)
            var oldCount4:Int = dstQueueCounter[142]!
            dstQueueCounter.updateValue(oldCount4 + 1, forKey: 142)
            
            return true
        }
        else {return false}
    }
    
    class func isStillQueueing(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!srcQueueTimer.isEmpty && p.captureTime - srcQueueTimer.last!.time > timeSpan){
            var key:Int = srcQueueTimer.removeLast().key
            srcQueueCounter[key]! = srcQueueCounter[key]! - 1
        }
        
        while(!dstQueueTimer.isEmpty && p.captureTime - dstQueueTimer.last!.time > timeSpan){
            var key:Int = dstQueueTimer.removeLast().key
            dstQueueCounter[key]! = dstQueueCounter[key]! - 1
        }
        
        for key in srcQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.srcPort <= portMax && p.srcPort >= portMin){
                    srcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    srcQueueCounter[key]! = srcQueueCounter[key]! + 1
            }
        }
        
        for key in dstQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.dstPort <= portMax && p.dstPort >= portMin){
                    dstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    dstQueueCounter[key]! = dstQueueCounter[key]! + 1
            }
        }
        
        while(!stopQueueTimer.isEmpty && p.captureTime - stopQueueTimer.last!.time > 2){
            var key:Int = stopQueueTimer.removeLast().key
            stopQueueCounter[key]! = stopQueueCounter[key]! - 1
        }
        
        
        if(p.packetLength <= 250 + 50 && p.packetLength >= 250
            && p.srcPort <= portMax && p.srcPort >= portMin){
                stopQueueTimer.insert(PacketTimer(key: 250, time: p.captureTime),atIndex: 0)
                stopQueueCounter[250]! = stopQueueCounter[250]! + 1
        }
            
        else if(p.packetLength == 78){
            stopQueueTimer.insert(PacketTimer(key: 78, time: p.captureTime),atIndex: 0)
            stopQueueCounter[78]! = stopQueueCounter[78]! + 1
        }
        
        //    println(srcQueueCounter)
        //    println(dstQueueCounter)
        //    println(stopQueueCounter)
        
        if(isProbablyGame){return true}
        if(stopQueueCounter[78] > 1 && stopQueueCounter[250] > 0){return false}
        //else if(srcQueueCounter[78] > 0 && srcQueueCounter[158] > 0 || isProbablyGame){return true}
        if((srcQueueCounter[78]! + srcQueueCounter[158]! + dstQueueCounter[126]! + dstQueueCounter[142]! > 2)
            && (srcQueueCounter[78] > 0 && srcQueueCounter[158] > 0 &&
                ( dstQueueCounter[126] > 0 ||  dstQueueCounter[142] > 0))){
                    return true}
        else {return false}
    }
    
    class func isGameReady(p:Packet) -> Bool{
        
        while(!gameTimerEarly.isEmpty && p.captureTime - gameTimerEarly.last!.time > 10){
            var key:Int = gameTimerEarly.removeLast().key
            packetCounterEarly[key]! = packetCounterEarly[key]! - 1
        }
        
        while(!dstGameTimer.isEmpty && p.captureTime - dstGameTimer.last!.time > 10){
            var key:Int = dstGameTimer.removeLast().key
            dstPacketCounter[key]! = dstPacketCounter[key]! - 1
        }
        
        while(!gameTimerLate.isEmpty && p.captureTime - gameTimerLate.last!.time > 10){
            var key:Int = gameTimerLate.removeLast().key
            packetCounterLate[key]! = packetCounterLate[key]! - 1
        }
        
        
        for key in packetCounterEarly.keys{
            if(p.packetLength <= key + 100 && p.packetLength >= key && (p.srcPort == queuePort || queuePort ==
                -1) && p.srcPort <= portMax && p.srcPort >= portMin){
                    gameTimerEarly.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    packetCounterEarly[key]! =  packetCounterEarly[key]! + 1
            }
        }
        
        for key in dstPacketCounter.keys{
            if(p.packetLength <= key + 5 && p.packetLength >= key && (p.dstPort == queuePort || queuePort ==
                -1) && p.dstPort <= portMax && p.dstPort >= portMin){
                    dstGameTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    dstPacketCounter[key]! = dstPacketCounter[key]! + 1
            }
        }
        
        for key in packetCounterLate.keys{
            if(p.packetLength <= key + 5 && p.packetLength >= key && (p.srcPort == queuePort || queuePort  ==
                -1) && p.srcPort <= portMax && p.srcPort >= portMin){
                    gameTimerLate.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    packetCounterLate[key]! = packetCounterLate[key]! + 1
            }
        }
        
        if(gameTimerEarly.count > 0 || gameTimerLate.count > 0 && p.packetLength > 1300){isProbablyGame = true}
        else{isProbablyGame = false}
        
        //    println(dstPacketCounter)
        //    println(packetCounterEarly)
        //    println(packetCounterLate)
        
        if(gameTimerEarly.count >= 3
            && packetCounterEarly[1300] < 3
            && gameTimerLate.count > 0
            && dstPacketCounter[78] > 1)
        {return true}
            
        else if((packetCounterLate[164] > 0 || packetCounterLate[174] > 0)
            && packetCounterLate[190] > 0
            && packetCounterLate[206] > 0
            && packetCounterEarly.count > 0)
        {return true}
        else if(gameTimerLate.count >= 6){return true}
        else {return false}
        
    }
    
    class func isInGame(p:Packet, timeSpan:Double, packetNumber:Int) -> Bool{
        
        var port:Int = -1
        if(p.srcPort >= 27000 && p.srcPort <= 28999){port = p.srcPort}
        else if(p.dstPort >= 27000 && p.dstPort <= 28999){port = p.dstPort}
        
        if(port != -1){
            inGameTimer.insert(PacketTimer(key: port, time: p.captureTime),atIndex: 0)
            if(inGamePacketCounter[port] == nil){inGamePacketCounter[port] = 1}
            else {inGamePacketCounter[port] = inGamePacketCounter[port]! + 1}
        }
        
        while(!inGameTimer.isEmpty && p.captureTime - inGameTimer.last!.time > timeSpan || inGameTimer.count >= inGameMaxSize){
            var remove = inGameTimer.removeLast().key
            inGamePacketCounter[remove] = inGamePacketCounter[remove]! - 1
        }
        
        var maxNumber = 0
        
        for packet in inGamePacketCounter{
            maxNumber = max(maxNumber, packet.1)
        }
        
        //    println(inGamePacketCounter)
        //    println(maxNumber)
        //    println(inGameTimer.count)
        if(maxNumber > 40){return true}
        else {return false}
    }
}