//
//  HOTSDetector.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class HOTSDetector: PacketDetector {

    static let HOTSFilter:String = "udp src port 1119 or udp src port 6113 or udp src port 1120 or udp src port 80 or udp src port 3724 or udp dst port 1119 or udp dst port 6113 or udp dst port 1120 or udp dst port 80 or udp dst port 3724"
    
    static let portMin:Int = 27000
    static let portMax:Int = 28000
    static let uselessPort:Int = -1
    
    static var queuePort:Int = -1
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [170:0]
    
    static var dstGameTimer:[PacketTimer] = [PacketTimer]()
    static var dstPacketCounter:[Int:Int] = [75:0]
    
    static var gameTimerLate:[PacketTimer] = [PacketTimer]()
    static var packetCounterLate:[Int:Int] = [60:0, 590:0]
    
    static var gameTimer:[PacketTimer] = [PacketTimer]()
    
    static var foundServer:Bool = false
    static var soonGame:Bool = false
    
    static let inGameMaxSize:Int = 101
    static var time:Double = -1
    
    override class func startDetection() {
        self.game = Game.HOTS
        self.detector = self
        self.countDownLength = 5
        updateStatus(Status.InQueue)
        super.startDetection()
        
        if(!isCapturing){
            dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
                self.packetParser.start_loop(self.HOTSFilter, detector: self
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
    
    class func resetGameTimer(){
        
        foundServer = false
        soonGame = false
        
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [170:0]
        
        gameTimerLate = [PacketTimer]()
        packetCounterLate = [60:0, 590:0]
        
        dstGameTimer = [PacketTimer]()
        dstPacketCounter = [75:0]
        
        gameTimer = [PacketTimer]()
    
    }
    
    override class func update(newPacket:Packet){
        
        //IN LOBBY
        if(status == Status.InLobby){
            
        }
            
            //IN QUEUE
        else  if(status == Status.InQueue){
        var inGame = isGame(newPacket, timeSpan:10.0, maxPacket:0, packetNumber:50)
        updateStatus(Status.GameReady)
        }
            
            //GAME READY
        else if(status == Status.GameReady){
        var inGame = isGame(newPacket, timeSpan:10.0, maxPacket:0, packetNumber:50)
        if(inGame){updateStatus(Status.InGame)}
        }
            
            //IN GAME
        else  if(status == Status.InGame){
            var inGame = isGame(newPacket, timeSpan:10.0, maxPacket:0, packetNumber:50)
            if(!inGame){updateStatus(Status.InLobby)}
        }
            
        else {
        }
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