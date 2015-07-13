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
    static var srcQueueCounter:[Int:Int] = [300:0, 400:0, 500:0, 600:0, 700:0, 800:0, 900:0, 1100:0]
    
    static var dstQueueTimer:[PacketTimer] = [PacketTimer]()
    static var dstQueueCounter:[Int:Int] = [100:0, 400:0, 500:0, 700:0, 800:0, 900:0]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [1300:0]
    
    static var stopSrcQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopSrcQueueCounter:[Int:Int] = [100:0, 300:0, 900:0, 1100:0]
    
    static var stopDstQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopDstQueueCounter:[Int:Int] = [100:0, 300:0, 900:0]
    
    static var queueStartTime:Double = -1
    
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
        srcQueueCounter = [300:0, 400:0, 500:0, 600:0, 800:0, 900:0, 1100:0]
        queuePort = -1
        dstQueueTimer = [PacketTimer]()
        dstQueueCounter =  [100:0, 400:0, 500:0, 700:0, 800:0, 900:0]
        
        stopSrcQueueTimer = [PacketTimer]()
        stopSrcQueueCounter = [100:0, 300:0, 800:0, 900:0, 1100:0]
        
        stopDstQueueTimer = [PacketTimer]()
        stopDstQueueCounter = [100:0, 300:0, 800:0, 900:0]
    }
    
    class func resetGameTimer(){
        
        foundServer = false
        soonGame = false
        
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [1300:0]
        queueStartTime = -1
        
        gameTimer = [PacketTimer]()
        
    }
    
    
    override class func update(newPacket:Packet){
        
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
            if(p.packetLength <= key + 99 && p.packetLength >= key && ports.contains(p.srcPort)){
                if((p.packetLength >= 600 && p.srcPort == 5223) || (p.packetLength < 600 && p.srcPort == 2099)){
                    srcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    srcQueueCounter[key]! =  srcQueueCounter[key]! + 1
                }
            }
        }
        
        for key in dstQueueCounter.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && ports.contains(p.dstPort)){
                if((p.packetLength >= 600 && p.dstPort == 5223) || (p.packetLength < 600 && p.dstPort == 2099)){
                    dstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    dstQueueCounter[key]! = dstQueueCounter[key]! + 1
                }
            }
        }
        
        println(srcQueueCounter)
        println(dstQueueCounter)
        println(srcQueueTimer.count)
        println(dstQueueTimer.count)
        
        
        if((srcQueueCounter[400] > 0 || srcQueueCounter[800] > 0 || srcQueueCounter[700] > 0) && (dstQueueCounter[500] > 0 || dstQueueCounter[800] > 0 || dstQueueCounter[700] > 0 || dstQueueCounter[400] > 0) && (srcQueueTimer.count >= 2 && dstQueueTimer.count >= 2) && (srcQueueTimer.count + dstQueueTimer.count >= 3)){
            queueStartTime = p.captureTime
            return true}
        else if((srcQueueCounter[300] > 0 || srcQueueCounter[400] > 0) && (dstQueueCounter[500] > 0 || dstQueueCounter[100] > 0) && (srcQueueTimer.count >= 3 && dstQueueTimer.count >= 3)){
            queueStartTime = p.captureTime
            return true}
        else{return false}
    }
    
    class func stoppedQueueing(p:Packet) -> Bool{
        
        while(!stopSrcQueueTimer.isEmpty && p.captureTime - stopSrcQueueTimer.last!.time > 2){
            var key:Int = stopSrcQueueTimer.removeLast().key
            stopSrcQueueCounter[key]! = stopSrcQueueCounter[key]! - 1
        }
        
        while(!stopDstQueueTimer.isEmpty && p.captureTime - stopDstQueueTimer.last!.time > 2){
            var key:Int = stopDstQueueTimer.removeLast().key
            stopDstQueueCounter[key]! = stopDstQueueCounter[key]! - 1
        }
        
        for key in stopSrcQueueCounter.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && ports.contains(p.srcPort)){
                stopSrcQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                stopSrcQueueCounter[key]! = stopSrcQueueCounter[key]! + 1
            }
        }
        
        for key in stopDstQueueCounter.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && ports.contains(p.dstPort)){
                stopDstQueueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                stopDstQueueCounter[key]! = stopDstQueueCounter[key]! + 1
            }
        }
        
        
        println(stopSrcQueueCounter)
        println(stopDstQueueCounter)
        
        if((stopSrcQueueCounter[100] > 0 || stopSrcQueueCounter[800] > 0) && (stopDstQueueCounter[300] > 0 || stopDstQueueCounter[800] > 0) && (stopSrcQueueTimer.count >= 2 && stopDstQueueTimer.count >= 2))
        {return true}
        else if((stopSrcQueueCounter[900] > 0 || stopSrcQueueCounter[1100] > 0 || stopSrcQueueCounter[300] > 0) &&
            (stopDstQueueCounter[100] > 0 || stopDstQueueCounter[300] > 0) && (stopSrcQueueTimer.count >= 3 && stopDstQueueTimer.count >= 3))
        {return true}
        else{return false}
    }
    
    
    class func isGameReady(p:Packet) -> Bool{
        
        while(!gameTimerEarly.isEmpty && p.captureTime - gameTimerEarly.last!.time > 3){
            var key:Int = gameTimerEarly.removeLast().key
            packetCounterEarly[key]! = packetCounterEarly[key]! - 1
        }
        
        for key in packetCounterEarly.keys{
            if(p.packetLength <= key + 99 && p.packetLength >= key && (p.srcPort == queuePort || queuePort == -1) && ports.contains(p.srcPort) && (p.captureTime - queueStartTime > 0.3)){
                gameTimerEarly.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                packetCounterEarly[key]! =  packetCounterEarly[key]! + 1
            }
        }
        
        println(packetCounterEarly)
        
        if(packetCounterEarly[1300] >= 2)
        {return true}
        else{return false}
    }
}