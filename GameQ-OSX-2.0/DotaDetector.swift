//
//  DotaReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:PacketDetector{
    
    static let dotaFilter:String = "udp src portrange 27000-28999 or udp dst portrange 27000-28999"
    static let portMin:Int = 27000
    static let portMax:Int = 27050
    
    static var queuePort:Int = -1
    static var srcQueueTimer:[PacketTimer] = [PacketTimer]()
    static var srcQueueCounter:[Int:Int] = [78:0, 158:0, 206:0, 270:0, 285:0]
    
    static var dstQueueTimer:[PacketTimer] = [PacketTimer]()
    static var dstQueueCounter:[Int:Int] = [78:0, 126:0, 174:0, 222:0]
    
    static var stopSrcQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopSrcQueueCounter:[Int:Int] = [78: 0, 250:0]
    
    static var stopDstQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopDstQueueCounter:[Int:Int] = [142: 0, 174:0, 206:0, 250:0]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
    
    static var gameTimerLate:[PacketTimer] = [PacketTimer]()
    static var packetCounterLate:[Int:Int] = [164:0, 174:0, 190:0, 206:0]
    
    static var dstGameTimer:[PacketTimer] = [PacketTimer]()
    static var dstPacketCounter:[Int:Int] = [78:0]
    
    static var isProbablyGame:Bool = false
    static var inGameTimer:[PacketTimer] = [PacketTimer]()
    static let inGameMaxSize:Int = 100
    static var inGamePacketCounter:[Int:Int] = [Int:Int]()
    
    static var spamDetector:[PacketTimer] = [PacketTimer]()
    
    static var saveCounter = 0;
    
    override class func startDetection() {
        self.game = Game.Dota2
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
        srcQueueCounter = [78:0, 158:0, 206:0, 270:0, 285:0]
        dstQueueTimer = [PacketTimer]()
        dstQueueCounter = [78:0, 126:0, 174:0, 222:0]
        
        queuePort = -1
        stopSrcQueueTimer = [PacketTimer]()
        stopSrcQueueCounter = [78: 0, 250:0]
        stopDstQueueTimer = [PacketTimer]()
        stopDstQueueCounter = [142: 0, 174:0, 206:0, 250:0]
    }
    
    class func resetGameTimer(){
        
        spamDetector = [PacketTimer]()
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
    
    override class func update(newPacket: Packet){
        
        //IN LOBBY
        if(status == Status.InLobby){
            
            var inGame:Bool = isInGame(newPacket, timeSpan: 5.0, packetNumber: 30)
            var gameReady:Bool = isGameReady(newPacket)
            var startedQueueing:Bool = queueStarted(newPacket, timeSpan: 2.0, maxPacket:5, packetNumber: 2)
            
            if(inGame){updateStatus(Status.InGame)}
            else if(gameReady){updateStatus(Status.GameReady)}
            else if(startedQueueing){updateStatus(Status.InQueue)}
        }
            
            //IN QUEUE
        else  if(status == Status.InQueue){
            var inGame:Bool = isInGame(newPacket, timeSpan: 5.0, packetNumber: 30)
            var gameReady:Bool = isGameReady(newPacket)
            var stillQueueing:Bool = isStillQueueing(newPacket, timeSpan: 30.0, maxPacket: 5, packetNumber: 2)
            
            if(inGame){updateStatus(Status.InGame)}
            else if(gameReady){updateStatus(Status.GameReady)}
            else if(!stillQueueing){updateStatus(Status.InLobby)
                resetQueueTimer()
            }
        }
            
            //GAME READY
        else if(status == Status.GameReady){
            var inGame:Bool = isInGame(newPacket, timeSpan: 6.0, packetNumber: 30)
            resetGameTimer()
            
            if(inGame){updateStatus(Status.InGame)
                resetQueueTimer()}
        }
            
            //IN GAME
        else  if(status == Status.InGame){
            var inGame:Bool = isInGame(newPacket, timeSpan: 3.0, packetNumber: 50)
            
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
        
        println(srcQueueCounter)
        println(dstQueueCounter)
        
        if(dstQueueCounter[174] >= 1 && (srcQueueCounter[270] >= 1 || srcQueueCounter[285] >= 1 ) && (srcQueueCounter[78] >= 1 || dstQueueCounter[78]! >= 1) && (dstQueueCounter[174]! + dstQueueCounter[222]! >= 2))
        {return true}
        else if(srcQueueCounter[78] >= 1 && dstQueueCounter[78]! >= 1 && dstQueueCounter[174] >= 1 && dstQueueCounter[222] >= 1 && dstQueueCounter[126] >= 1){return true}
        else if(srcQueueCounter[78] >= 2 && dstQueueCounter[78]! >= 1 && dstQueueCounter[222] >= 1 && dstQueueCounter[126] >= 1){return true}
        else {return false}
    }
    
    class func isStillQueueing(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!stopSrcQueueTimer.isEmpty && p.captureTime - stopSrcQueueTimer.last!.time > 2.0){
            var key:Int = stopSrcQueueTimer.removeLast().key
            stopSrcQueueCounter[key]! = stopSrcQueueCounter[key]! - 1
        }
        
        while(!stopDstQueueTimer.isEmpty && p.captureTime - stopDstQueueTimer.last!.time > 2.0){
            var key:Int = stopDstQueueTimer.removeLast().key
            stopDstQueueCounter[key]! = stopDstQueueCounter[key]! - 1
        }
        
        
        for key in stopSrcQueueCounter.keys{
            if((p.packetLength <= key + 10 && p.packetLength >= key)
                && p.srcPort <= portMax && p.srcPort >= portMin){
                    stopSrcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    stopSrcQueueCounter[key]! = stopSrcQueueCounter[key]! + 1
            }
        }
        
        
        for key in stopDstQueueCounter.keys{
            if((p.packetLength <= key + 10 && p.packetLength >= key)
                && p.dstPort <= portMax && p.dstPort >= portMin){
                    stopDstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    stopDstQueueCounter[key]! = stopDstQueueCounter[key]! + 1
            }
        }
        
        println(stopSrcQueueCounter)
        println(stopDstQueueCounter)
        
        if(isProbablyGame){return true}
        if(stopSrcQueueCounter[250] >= 1 && stopDstQueueCounter[142] >= 1 && (stopDstQueueCounter[174] >= 1 || stopDstQueueCounter[206] >= 1)){return false}
        else if(stopSrcQueueCounter[250] >= 1 && stopDstQueueCounter[142] >= 1 && stopDstQueueCounter[206] >= 1){return false}
        else if(stopSrcQueueCounter[78] >= 2 && stopDstQueueCounter[142] >= 1 && stopDstQueueCounter[206] >= 1){return false}
        else {return true}
    }
    
    class func isGameReady(p:Packet) -> Bool{
        
        while(!spamDetector.isEmpty && p.captureTime - spamDetector.last!.time > 1.0){
            spamDetector.removeLast()
        }
        
        spamDetector.insert(PacketTimer(key: p.packetLength, time: p.captureTime), atIndex: 0)
        
        while(!gameTimerEarly.isEmpty && p.captureTime - gameTimerEarly.last!.time > 10.0){
            var key:Int = gameTimerEarly.removeLast().key
            packetCounterEarly[key]! = packetCounterEarly[key]! - 1
        }
        
        while(!dstGameTimer.isEmpty && p.captureTime - dstGameTimer.last!.time > 10.0){
            var key:Int = dstGameTimer.removeLast().key
            dstPacketCounter[key]! = dstPacketCounter[key]! - 1
        }
        
        while(!gameTimerLate.isEmpty && p.captureTime - gameTimerLate.last!.time > 10.0){
            var key:Int = gameTimerLate.removeLast().key
            packetCounterLate[key]! = packetCounterLate[key]! - 1
        }
        
        
        if(spamDetector.count < 20){
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
            
            println(queuePort)
            for key in packetCounterLate.keys{
                if(p.packetLength <= key + 5 && p.packetLength >= key && (p.srcPort == queuePort || queuePort  ==
                    -1) && p.srcPort <= portMax && p.srcPort >= portMin){
                        gameTimerLate.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                        packetCounterLate[key]! = packetCounterLate[key]! + 1
                }
            }
        }
        
        println(packetCounterEarly)
        println(packetCounterLate)
        
        if(gameTimerEarly.count > 0 || gameTimerLate.count > 0 && p.packetLength > 1300){isProbablyGame = true}
        else{isProbablyGame = false}
        
        
        println(spamDetector.count)
        
        
        if(gameTimerEarly.count >= 3
            && packetCounterEarly[1300] < 3
            && gameTimerLate.count > 0
            && dstPacketCounter[78] > 1
            && gameTimerEarly.first?.time < gameTimerLate.last?.time)
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
        if(maxNumber > 70){return true}
        else {return false}
    }
}