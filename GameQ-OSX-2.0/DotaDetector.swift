//
//  DotaReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:PacketDetector{
    
    static let dotaFilter:String = "udp src portrange 27000-27030 or udp dst port 27005 or udp src port 4380"

    static var queuePort:Int = -1
    static var timer78:Double = -1
    static var timer158:Double = -1
    static let queueKeys:[Int] = [78,158]
    
    static var queueTimer:[PacketTimer] = [PacketTimer]()
    static var queueCounter:[Int:Int] = [78:0, 158:0, 270:0, 285:0]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
    
    static var gameTimerLate:[PacketTimer] = [PacketTimer]()
    static var packetCounterLate:[Int:Int] = [164:0, 174:0, 190:0, 206:0]
    
    static var inGameTimer:[PacketTimer] = [PacketTimer]()
    
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
        inGameTimer = [PacketTimer]()
        queueTimer = [PacketTimer]()
        queueCounter = [78:0, 158:0, 270:0, 285:0]
    }
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch MasterController.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            if(startedQueueing(newPacket, timeSpan: 30, maxPacket: 5, packetNumber: 2)){MasterController.updateStatus(Status.InQueue)}
            break
            
        case Status.InQueue:
            var gameLate:Bool = isGameLate(newPacket, timeSpan: 10, maxPacket: 5, packetNumber: 6)
            var gameEarly:Bool = isGameEarly(newPacket, timeSpan: 9, maxPacket: 99, packetNumber: 3)
            var stillQueueing:Bool = isStillQueueing(newPacket, timeSpan: 30, maxPacket: 5, packetNumber: 2)
                       
            if(gameLate){MasterController.updateStatus(Status.GameReady)}
            else if(gameEarly){MasterController.updateStatus(Status.GameReady)}
            else if(!stillQueueing){MasterController.updateStatus(Status.InLobby)}
            break
            
        case Status.GameReady:
            var inGame = isInGame(newPacket, timeSpan: 5, packetNumber: 30)
            if(inGame){MasterController.updateStatus(Status.InGame)}
            break
            
        case Status.InGame:
            break
        }
    }
    
    class func startedQueueing(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
       
        while(!queueTimer.isEmpty && p.captureTime - queueTimer.last!.time > timeSpan){
            var key:Int = queueTimer.removeLast().key
            var oldCount:Int = queueCounter[key]!
            queueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        for key in queueCounter.keys{
            if(p.packetLength <= key + maxPacket && p.packetLength >= key){
                queueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                var oldCount:Int = queueCounter[key]!
                queueCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        //println(queueCounter)
        if(queueCounter[78] > 0 && queueCounter[158] > 0){
        queuePort = p.srcPort
        return true
        }
        else {return false}
    }
    
    class func isStillQueueing(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!queueTimer.isEmpty && p.captureTime - queueTimer.last!.time > timeSpan){
            var key:Int = queueTimer.removeLast().key
            var oldCount:Int = queueCounter[key]!
            queueCounter.updateValue(oldCount - 1, forKey: key)
        }
        
        for key in queueCounter.keys{
            if(p.packetLength <= key + maxPacket && p.packetLength >= key){
                queueTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                var oldCount:Int = queueCounter[key]!
                queueCounter.updateValue(oldCount + 1, forKey: key)
            }
        }
        
        //println(queueCounter)
        if(queueCounter[78] > 0 || queueCounter[158] > 0)
        {
            timer78 = p.captureTime
            timer158 = p.captureTime
            queuePort = p.srcPort
            return true}
        else {return false}
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
        
            if(gameTimerEarly.count >= packetNumber
            && packetCounterEarly[1300] < 2
            && gameTimerLate.count > 0)
            {return true}
            
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