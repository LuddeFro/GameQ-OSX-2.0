//
//  HoNDetector.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/29/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class HoNDetector: GameDetector, PacketDetector {
    
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    static var packetParser:PacketParser = PacketParser.getSharedInstance()
    
    static let HoNFilter:String = "udp src portrange 11235-11335 or udp dst portrange 11235-11335"
    
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
        self.game = Game.HoN
        self.detector = self
        self.countDownLength = 5
        updateStatus(Status.InQueue)
        super.startDetection()
        
        if(!isCapturing){
            dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
                self.packetParser.start_loop(self.HoNFilter, detector: self
                )})}
        isCapturing = true
    }
    
    override class func resetDetection(){
        super.resetDetection()
        resetGameTimer()
    }
    
    
    override class func saveDetection(){
        super.saveDetection()
        dataHandler.logPackets(packetQueue)
        packetQueue = [Packet]()
    }
    
    override class func saveMissedDetection(){
        super.saveMissedDetection()
        dataHandler.logPackets(packetQueue)
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
    
    override class func getStatusString() -> String{
        
        var statusString = ""
        
        switch self.status {
            
        case Status.Offline:
            statusString =  Status.Offline.rawValue
            break
        case Status.Online:
            statusString =  Status.Online.rawValue
            break
        case Status.InLobby:
            statusString =  "Detecting Game"
            break
        case Status.InQueue:
            statusString =  "Detecting Game"
            break
        case Status.GameReady:
            statusString =  Status.GameReady.rawValue
            break
        case Status.InGame:
            statusString =  Status.InGame.rawValue
            break
        }
        return statusString
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
    
    class func update(newPacket:Packet){
        
        packetQueue.insert(newPacket, atIndex: 0)
        if packetQueue.count >= queueMaxSize {
            packetQueue.removeLast()
        }
        
        //IN LOBBY
        if(status == Status.InLobby){
            
        }
            
            //IN QUEUE
        else  if(status == Status.InQueue){
            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:50)
            updateStatus(Status.GameReady)
        }
            
            //GAME READY
        else if(status == Status.GameReady){
            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:50)
            if(inGame){updateStatus(Status.InGame)}
        }
            
            //IN GAME
        else  if(status == Status.InGame){
            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:50)
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