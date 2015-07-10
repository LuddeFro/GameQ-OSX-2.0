//
//  LoLDetector.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/29/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class LoLDetector: PacketDetector {
    
    static let LoLFilter:String = "tcp src port 2099 or tcp src port 5223 or tcp src port 5222 or tcp dst port 2099 or tcp dst port 5223 or tcp dst port 5222"
    
    static let ports =  Set([2099, 5223, 5222])
    
    static var queuePort:Int = -1
    
    static var srcQueueTimer:[PacketTimer] = [PacketTimer]()
    static var srcQueueCounter:[Int:Int] = [400:0, 500:0, 600:0, 700:0, 800:0, 900:0]
    
    static var dstQueueTimer:[PacketTimer] = [PacketTimer]()
    static var dstQueueCounter:[Int:Int] = [400:0, 500:0, 600:0, 700:0, 800:0, 900:0]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [1300:0]
    
    static var stopQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopQueueCounter:[Int:Int] = [100:0, 300:0,400:0, 500:0, 600:0, 700:0, 800:0, 900:0]
    
    //    static var dstGameTimer:[PacketTimer] = [PacketTimer]()
    //    static var dstPacketCounter:[Int:Int] = [-1:0]
    
    static var gameTimer:[PacketTimer] = [PacketTimer]()
    
    static var foundServer:Bool = false
    static var soonGame:Bool = false
    
    static let inGameMaxSize:Int = 101
    static var time:Double = -1
    
    override class func startDetection() {
        self.game = Game.LoL
        self.detector = self
        self.countDownLength = 10
        updateStatus(Status.InLobby)
        super.startDetection()
        
        if(!isCapturing){
            dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
                self.packetParser.start_loop(self.LoLFilter, detector: self
                )})}
        isCapturing = true
    }
    
    override class func resetDetection(){
        super.resetDetection()
        resetGameTimer()
    }
    
    
    override class func saveDetection(){
        super.saveDetection()
        dataHandler.logPackets(fileToString())
        packetQueue = [Packet]()
    }
    
    override class func saveMissedDetection(){
        super.saveMissedDetection()
        dataHandler.logPackets(fileToString())
        packetQueue = [Packet]()
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
        srcQueueCounter = [400:0, 500:0, 600:0, 700:0, 800:0, 900:0]
        queuePort = -1
        dstQueueTimer = [PacketTimer]()
        dstQueueCounter = [400:0, 500:0, 600:0, 700:0, 800:0, 900:0]
        
        stopQueueTimer = [PacketTimer]()
        stopQueueCounter = [100:0, 300:0,400:0, 500:0, 600:0, 700:0, 800:0, 900:0]
    }
    
    class func resetGameTimer(){
        
        foundServer = false
        soonGame = false
        
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [1300:0]
        
        //        dstGameTimer = [PacketTimer]()
        //        dstPacketCounter = [-1:0]
        
        gameTimer = [PacketTimer]()
        
    }
    
    
    override class func update(newPacket:Packet){
        
        packetQueue.insert(newPacket, atIndex: 0)
        if packetQueue.count >= queueMaxSize {
            packetQueue.removeLast()
        }
        
        //IN LOBBY
        if(status == Status.InLobby){
            var queueing = isQueueing(newPacket)
            if(queueing){updateStatus(Status.InQueue)
                resetQueueTimer()}
        }
            
            //IN QUEUE
        else  if(status == Status.InQueue){
            var gameReady = isGameReady(newPacket)
            var stoppedQueue = stoppedQueueing(newPacket)
            
            if(gameReady){updateStatus(Status.GameReady)}
            else if(stoppedQueue){updateStatus(Status.InLobby)
                resetQueueTimer()}
        }
            
            //GAME READY
        else if(status == Status.GameReady){
            //            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:50)
            //            if(inGame){updateStatus(Status.InGame)}
        }
            
            //IN GAME
        else  if(status == Status.InGame){
        }
            
        else {
        }
        
        println()
    }
    
    class func isQueueing(p:Packet) -> Bool{
        
        while(!srcQueueTimer.isEmpty && p.captureTime - srcQueueTimer.last!.time > 2){
            var key:Int = srcQueueTimer.removeLast().key
            srcQueueCounter[key]! = srcQueueCounter[key]! - 1
        }
        
        while(!dstQueueTimer.isEmpty && p.captureTime - dstQueueTimer.last!.time > 2){
            var key:Int = dstQueueTimer.removeLast().key
            dstQueueCounter[key]! = dstQueueCounter[key]! - 1
        }
        
        
        for key in srcQueueCounter.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && (p.srcPort == queuePort || queuePort == -1) && ports.contains(p.srcPort)){
                srcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                srcQueueCounter[key]! =  srcQueueCounter[key]! + 1
            }
        }
        
        for key in dstQueueCounter.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && ports.contains(p.dstPort)){
                dstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                dstQueueCounter[key]! = dstQueueCounter[key]! + 1
            }
        }
        
        println(srcQueueCounter)
        println(dstQueueCounter)
        println(srcQueueTimer.count)
        println(dstQueueTimer.count)
        
        if((srcQueueCounter[400] > 0 || srcQueueCounter[800] > 0) && (dstQueueCounter[500] > 0 || dstQueueCounter[700] > 0) && (srcQueueTimer.count + dstQueueTimer.count >= 3))
        {return true}
        else{return false}
    }
    
    class func stoppedQueueing(p:Packet) -> Bool{
        
        while(!stopQueueTimer.isEmpty && p.captureTime - stopQueueTimer.last!.time > 2){
            var key:Int = stopQueueTimer.removeLast().key
            stopQueueCounter[key]! = stopQueueCounter[key]! - 1
        }
        
        for key in stopQueueCounter.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && (ports.contains(p.dstPort) || ports.contains(p.srcPort))){
                stopQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                stopQueueCounter[key]! = stopQueueCounter[key]! + 1
            }
        }
        
        println(stopQueueCounter)
        
        
        
        if((stopQueueCounter[300] > 0 || stopQueueCounter[700] > 0) && (stopQueueCounter[800] > 0 || stopQueueCounter[100] > 0) && (stopQueueTimer.count >= 3))
        {return true}
        else{return false}
    }
    
    
    class func isGameReady(p:Packet) -> Bool{
        
        while(!gameTimerEarly.isEmpty && p.captureTime - gameTimerEarly.last!.time > 3){
            var key:Int = gameTimerEarly.removeLast().key
            packetCounterEarly[key]! = packetCounterEarly[key]! - 1
        }
        //
        //        while(!dstGameTimer.isEmpty && p.captureTime - dstGameTimer.last!.time > 3){
        //            var key:Int = dstGameTimer.removeLast().key
        //            dstPacketCounter[key]! = dstPacketCounter[key]! - 1
        //        }
        
        
        for key in packetCounterEarly.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && (p.srcPort == queuePort || queuePort == -1) && ports.contains(p.srcPort)){
                gameTimerEarly.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                packetCounterEarly[key]! =  packetCounterEarly[key]! + 1
            }
        }
        
        //        for key in dstPacketCounter.keys{
        //            if(p.packetLength <= key + 30 && p.packetLength >= key && ports.contains(p.dstPort)){
        //                dstGameTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
        //                dstPacketCounter[key]! = dstPacketCounter[key]! + 1
        //            }
        //        }
        
        println(packetCounterEarly)
        //        println(dstPacketCounter)
        
        if(packetCounterEarly[1300] > 1){return true}
        else{return false}
    }
    
    class func isGame(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!gameTimer.isEmpty && p.captureTime - gameTimer.last!.time > timeSpan || gameTimer.count >= inGameMaxSize){
            gameTimer.removeLast()
        }
        
        gameTimer.insert(PacketTimer(key: p.srcPort, time: p.captureTime),atIndex: 0)
        
        if(gameTimer.count >= packetNumber){return true}
        else {return false}
    }
    
}