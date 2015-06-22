//
//  DotaReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:PacketDetector
{
    
    static let dotaFilter:String = "udp src portrange 27000-27050 or udp dst portrange 27000-27050"
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
    
    static var saveCounter = 0;
    
    override class func start() {
        detector = self
        if(!isCapturing){
            dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
                self.packetParser.start_loop(self.dotaFilter)
            })
        }
        super.start()
    }
    
    override class func reset(){
        super.reset()
        resetsrcQueueTimer()
        resetdstQueueTimer()
        resetGameTimer()
        resetInGameTimer()
        saveCounter = 0;
    }
    
    class func resetsrcQueueTimer(){
        srcQueueTimer = [PacketTimer]()
        srcQueueCounter = [78:0, 158:0, 270:0, 285:0]
        queuePort = -1
        stopQueueTimer = [PacketTimer]()
        stopQueueCounter = [78: 0, 250:0, 1300: 0]
    }
    
    class func  resetdstQueueTimer(){
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
    }
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch MasterController.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            var inGame = isInGame(newPacket, timeSpan: 5, packetNumber: 40)
            var gameReady = isGameReady(newPacket)
            
            if(inGame){MasterController.updateStatus(Status.InGame)}
                
            else if(gameReady){
                MasterController.updateStatus(Status.GameReady)
                resetsrcQueueTimer()
            }
                
            else if(startedQueueing(newPacket, timeSpan: 30, maxPacket:5, packetNumber: 2))
            {MasterController.updateStatus(Status.InQueue)}
            
            break
            
        case Status.InQueue:
            var gameReady = isGameReady(newPacket)
            var stillQueueing:Bool = isStillQueueing(newPacket, timeSpan: 30, maxPacket: 5, packetNumber: 2)
            
            if(gameReady){
                MasterController.updateStatus(Status.GameReady)
                resetsrcQueueTimer()
            }
            else if(!stillQueueing){
                MasterController.updateStatus(Status.InLobby)
                resetsrcQueueTimer()
            }
            break
            
        case Status.GameReady:
            saveCounter++
            
            if(saveCounter == 10 && !MasterController.isTesting){
                MasterController.saveCapture()
                //MasterController.stopDetection()
            }
            
            var inGame = isInGame(newPacket, timeSpan: 5, packetNumber: 40)
            
            if(inGame){MasterController.updateStatus(Status.InGame)}
            break
            
        case Status.InGame:
            break
        }
        
        println()
    }
    
    class func startedQueueing(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!srcQueueTimer.isEmpty && p.captureTime - srcQueueTimer.last!.time > timeSpan){
            var key:Int = srcQueueTimer.removeLast().key
            var oldCount:Int = srcQueueCounter[key]!
            srcQueueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        while(!dstQueueTimer.isEmpty && p.captureTime - dstQueueTimer.last!.time > timeSpan){
            var key:Int = dstQueueTimer.removeLast().key
            var oldCount:Int = dstQueueCounter[key]!
            dstQueueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        for key in srcQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.srcPort <= portMax && p.srcPort >= portMin){
                    srcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = srcQueueCounter[key]!
                    srcQueueCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        for key in dstQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.dstPort <= portMax && p.dstPort >= portMin){
                    dstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = dstQueueCounter[key]!
                    dstQueueCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        println(srcQueueCounter)
        println(dstQueueCounter)
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
            var oldCount:Int = srcQueueCounter[key]!
            srcQueueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        while(!dstQueueTimer.isEmpty && p.captureTime - dstQueueTimer.last!.time > timeSpan){
            var key:Int = dstQueueTimer.removeLast().key
            var oldCount:Int = dstQueueCounter[key]!
            dstQueueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        for key in srcQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.srcPort <= portMax && p.srcPort >= portMin){
                    srcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = srcQueueCounter[key]!
                    srcQueueCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        for key in dstQueueCounter.keys{
            if((p.packetLength <= key + maxPacket && p.packetLength >= key)
                && p.dstPort <= portMax && p.dstPort >= portMin){
                    dstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = dstQueueCounter[key]!
                    dstQueueCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        while(!stopQueueTimer.isEmpty && p.captureTime - stopQueueTimer.last!.time > 2){
            var key:Int = stopQueueTimer.removeLast().key
            var oldCount:Int = stopQueueCounter[key]!
            stopQueueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        
        if(p.packetLength <= 250 + 50 && p.packetLength >= 250){
            stopQueueTimer.insert(PacketTimer(key: 250, time: p.captureTime),atIndex: 0)
            var oldCount:Int = stopQueueCounter[250]!
            stopQueueCounter.updateValue(oldCount + 1, forKey: 250)
        }
            
        else if(p.packetLength == 78){
            stopQueueTimer.insert(PacketTimer(key: 78, time: p.captureTime),atIndex: 0)
            var oldCount:Int = stopQueueCounter[78]!
            stopQueueCounter.updateValue(oldCount + 1, forKey: 78)
        }
        
        println(srcQueueCounter)
        println(dstQueueCounter)
        
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
            var oldCount:Int = packetCounterEarly[key]!
            packetCounterEarly.updateValue(oldCount - 1, forKey: key)
        }
        
        while(!dstGameTimer.isEmpty && p.captureTime - dstGameTimer.last!.time > 10){
            var key:Int = dstGameTimer.removeLast().key
            var oldCount:Int = dstPacketCounter[key]!
            dstPacketCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        while(!gameTimerLate.isEmpty && p.captureTime - gameTimerLate.last!.time > 10){
            var key:Int = gameTimerLate.removeLast().key
            var oldCount:Int = packetCounterLate[key]!
            packetCounterLate.updateValue(oldCount - 1, forKey: key)
        }
        
        
        for key in packetCounterEarly.keys{
            if(p.packetLength <= key + 100 && p.packetLength >= key && (p.srcPort == queuePort || queuePort ==
                -1)){
                    gameTimerEarly.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = packetCounterEarly[key]!
                    packetCounterEarly.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        for key in dstPacketCounter.keys{
            if(p.packetLength <= key + 5 && p.packetLength >= key && (p.dstPort == queuePort || queuePort ==
                -1)){
                    dstGameTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = dstPacketCounter[key]!
                    dstPacketCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        for key in packetCounterLate.keys{
            if(p.packetLength <= key + 5 && p.packetLength >= key && (p.srcPort == queuePort || queuePort  ==
                -1)){
                    gameTimerLate.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = packetCounterLate[key]!
                    packetCounterLate.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        if(gameTimerEarly.count > 0 || gameTimerLate.count > 0 && p.packetLength > 1300){isProbablyGame = true}
        else{isProbablyGame = false}
        
        println(dstPacketCounter)
        println(packetCounterEarly)
        println(packetCounterLate)
        
        if(gameTimerEarly.count >= 3
            && packetCounterEarly[1300] < 3
            && gameTimerLate.count > 0
            && dstPacketCounter[78] > 1)
        {return true}
            
        else if((packetCounterLate[164] > 0 || packetCounterLate[174] > 0)
            && packetCounterLate[190] > 0
            && packetCounterLate[206] > 0)
        {return true}
        else if(gameTimerLate.count >= 6){return true}
        else {return false}
        
    }
    
    class func isInGame(p:Packet, timeSpan:Double, packetNumber:Int) -> Bool{
        
        while(!inGameTimer.isEmpty && p.captureTime - inGameTimer.last!.time > timeSpan){
            inGameTimer.removeLast()
        }
        
        inGameTimer.insert(PacketTimer(key: p.srcPort, time: p.captureTime),atIndex: 0)
        
        if(inGameTimer.count >= packetNumber){return true}
        else {return false}
    }
}