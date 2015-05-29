//
//  DotaReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaReader:PacketReader{
    
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    
    static var queuePort:Int = -1
    static var timer78:Double = -1
    static var timer158:Double = -1
    static let queueKeys:[Int] = [78,158]
    
    static var gameTimer:[PacketTimer] = [PacketTimer]()
    static var packetCounter:[Int:Int] = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
    
    static var gameTimer2:[PacketTimer] = [PacketTimer]()
    static var packetCounter2:[Int:Int] = [164:0, 174:0, 190:0, 206:0]
    
    
    struct PacketTimer {
        var key:Int = -1
        var time:Double = -1
    }
    
    class func addPacketToQueue(packet:Packet) {
        packetQueue.insert(packet, atIndex: 0)
        if packetQueue.count >= queueMaxSize {
            packetQueue.removeLast()
        }
    }
    
    override class func handle(srcPort:Int, dstPort:Int, iplen:Int) {
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        updateStatus(newPacket);
    }
    
    class func save(fileName:String) {
        DataHandler.logPackets(packetQueue, fileName:fileName)
    }
    
    class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch DotaDetector.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
           
//            var gameTime:Bool = isGame(newPacket, timeSpan: 5, maxPacket: 5, packetNumber: 3)
            
            //if(gameTime){DotaDetector.updateStatus(Status.GameReady)}
            if(startedQueueing(newPacket)){DotaDetector.updateStatus(Status.InQueue)}
            break
            
        case Status.InQueue:
//            var gameTime:Bool = isQueueToGame(newPacket, timeSpan: 5, maxPacket: 99, packetNumber: 4)
            var gameTime2:Bool = isGame(newPacket, timeSpan: 5, maxPacket: 5, packetNumber: 3)
            
//            if(gameTime){DotaDetector.updateStatus(Status.GameReady)}
            if(gameTime2){DotaDetector.updateStatus(Status.GameReady)}
            else if(stoppedQueueing(newPacket)){DotaDetector.updateStatus(Status.InLobby)}
            else if(!isStillQueueing(newPacket)){DotaDetector.updateStatus(Status.InLobby)}
            break
            
        case Status.GameReady:
            break
            
        case Status.InGame:
            break
        }
    }
    
    class func startedQueueing(packet:Packet) -> Bool{
        
        if(packet.packetLength == 270){
            timer78 = packet.captureTime
            timer158 = packet.captureTime
            return true
        }
        
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
    
    class func isGame(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) ->
        Bool{
            
            while(!gameTimer2.isEmpty && p.captureTime - gameTimer2.last!.time > timeSpan){
                var key:Int = gameTimer2.removeLast().key
                var oldCount:Int = packetCounter2[key]!
                packetCounter2.updateValue(oldCount - 1, forKey: key)
            }
            
            for key in packetCounter2.keys{
                if(p.packetLength <= key + maxPacket && p.packetLength >= key && p.srcPort == queuePort){
                    gameTimer2.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = packetCounter2[key]!
                    packetCounter2.updateValue(oldCount + 1, forKey: key)
                }
            }
            
            println(packetCounter2);
            println(gameTimer2.count)
            if(gameTimer2.count >= packetNumber
            && (packetCounter2[164] > 0 || packetCounter2[174] > 0)
            && packetCounter2[190] > 0
            && packetCounter2[206] > 0)
            {return true}
            else {return false}
    }
    
    class func isQueueToGame(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) ->
        Bool{
            
            while(!gameTimer.isEmpty && p.captureTime - gameTimer.last!.time > timeSpan){
                var key:Int = gameTimer.removeLast().key
                var oldCount:Int = packetCounter[key]!
                packetCounter.updateValue(oldCount - 1, forKey: key)
            }
            
            for key in packetCounter.keys{
                if(p.packetLength <= key + maxPacket && p.packetLength >= key && p.srcPort == queuePort){
                    gameTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    var oldCount:Int = packetCounter[key]!
                    packetCounter.updateValue(oldCount + 1, forKey: key)
                }
            }
            
            println(packetCounter)
            if(gameTimer.count >= packetNumber && packetCounter[1300] < 2){return true}
            else {return false}
    }
    
    class func isStillInGame(){
        
    }
}