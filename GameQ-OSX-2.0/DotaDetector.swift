//
//  DotaReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:PacketReader{
    
    static let dotaFilter:String = "udp src portrange 27000-27030 or udp dst port 27005 or udp src port 4380"

    static var queuePort:Int = -1
    static var timer78:Double = -1
    static var timer158:Double = -1
    static let queueKeys:[Int] = [78,158]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
    
    static var gameTimerLate:[PacketTimer] = [PacketTimer]()
    static var packetCounterLate:[Int:Int] = [164:0, 174:0, 190:0, 206:0]
    
    override class func start() {
        super.start()
        detector = self
        dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
            PacketParser.start_loop(self.dotaFilter)
        })
    }
    
    override class func reset(){
        packetQueue = [Packet]()
        queuePort = -1
        timer78 = -1
        timer158 = -1
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
        gameTimerLate = [PacketTimer]()
        packetCounterLate = [164:0, 174:0, 190:0, 206:0]
    }
    
    override class func handle(srcPort:Int, dstPort:Int, iplen:Int) {
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        updateStatus(newPacket);
    }
    
    class func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double) {
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen, time: time)
         println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        updateStatus(newPacket);
    }
    
    class func addPacketToQueue(packet:Packet) {
        packetQueue.insert(packet, atIndex: 0)
        if packetQueue.count >= queueMaxSize {
            packetQueue.removeLast()
        }
    }
    
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch MasterController.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            if(startedQueueing(newPacket)){MasterController.updateStatus(Status.InQueue)}
            break
            
        case Status.InQueue:
            var gameEarly:Bool = isGameEarly(newPacket, timeSpan: 5, maxPacket: 99, packetNumber: 3)
            var gameLate:Bool = isGameLate(newPacket, timeSpan: 10, maxPacket: 5, packetNumber: 6)
            
            if(gameEarly){MasterController.updateStatus(Status.GameReady)}
            else if(gameLate){MasterController.updateStatus(Status.GameReady)}
            //else if(stoppedQueueing(newPacket)){DotaDetector.updateStatus(Status.InLobby)}
            else if(!isStillQueueing(newPacket)){MasterController.updateStatus(Status.InLobby)}
            break
            
        case Status.GameReady:
            break
            
        case Status.InGame:
            break
        }
    }
    
    class func startedQueueing(packet:Packet) -> Bool{
        
//        if(packet.packetLength == 270 && (timer78 != -1 || timer158 != -1)){
//            timer78 = packet.captureTime
//            timer158 = packet.captureTime
//            return true
//        }
        
        if(packet.captureTime - timer78 > 30){timer78 = -1}
        if(packet.captureTime - timer158 > 30){timer158 = -1}
        
        if(packet.packetLength == 78){
            timer78 = packet.captureTime
            queuePort = packet.srcPort}
        if(packet.packetLength == 158){
            timer158 = packet.captureTime
            queuePort = packet.srcPort}
        
        if(timer78 != -1 && timer158 != -1){return true}
        else {return false}
    }
    
    class func isStillQueueing(packet:Packet) -> Bool{
        
        if(packet.captureTime - timer78 > 40){timer78 = -1}
        if(packet.captureTime - timer158 > 40){timer158 = -1}
        
        if(packet.packetLength == 78){
            timer78 = packet.captureTime
            queuePort = packet.srcPort}
        if(packet.packetLength == 158){
            timer158 = packet.captureTime
            queuePort = packet.srcPort}
    
        if(timer78 != -1 || timer158 != -1){return true}
        else {return false}
    }
    
    class func stoppedQueueing(packet:Packet) -> Bool{
        
        if(packet.packetLength == 254 || packet.packetLength == 286){
            timer78 = -1
            timer158 = -1
            return true
        }
        else{return false}
    }
    
    class func isGameLate(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
            
            while(!gameTimerLate.isEmpty && p.captureTime - gameTimerLate.last!.time > timeSpan){
                var key:Int = gameTimerLate.removeLast().key
                var oldCount:Int = packetCounterLate[key]!
                packetCounterLate.updateValue(oldCount - 1, forKey: key)
            }
            
            for key in packetCounterLate.keys{
                if(p.packetLength <= key + maxPacket && p.packetLength >= key && p.srcPort == queuePort){
                    gameTimerLate.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = packetCounterLate[key]!
                    packetCounterLate.updateValue(oldCount + 1, forKey: key)
                }
            }
        
            println(packetCounterLate)
            if((packetCounterLate[164] > 0 || packetCounterLate[174] > 0)
            && packetCounterLate[190] > 0
            && packetCounterLate[206] > 0)
            {return true}
            else if(gameTimerLate.count >= packetNumber){return true}
            else {return false}
    }
    
    class func isGameEarly(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
            
            while(!gameTimerEarly.isEmpty && p.captureTime - gameTimerEarly.last!.time > timeSpan){
                var key:Int = gameTimerEarly.removeLast().key
                var oldCount:Int = packetCounterEarly[key]!
                packetCounterEarly.updateValue(oldCount - 1, forKey: key)
            }
            
            for key in packetCounterEarly.keys{
                if(p.packetLength <= key + maxPacket && p.packetLength >= key && p.srcPort == queuePort){
                    gameTimerEarly.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = packetCounterEarly[key]!
                    packetCounterEarly.updateValue(oldCount + 1, forKey: key)
                }
            }
        
            println(packetCounterEarly)
            if(gameTimerEarly.count >= packetNumber
            && packetCounterEarly[1300] < 2
            && gameTimerLate.count > 0)
            {return true}
            
            else {return false}
    }
    
    class func isStillInGame(){
        
    }
}