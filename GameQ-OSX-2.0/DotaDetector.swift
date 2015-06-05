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
    static var queueTimer:[PacketTimer] = [PacketTimer]()
    static var queueCounter:[Int:Int] = [78:0, 158:0, 270:0, 285:0]
    static var stopQueueTimer:[PacketTimer] = [PacketTimer]()
    static var stopQueueCounter:[Int:Int] = [78: 0, 250:0, 1300: 0]
    
    static var gameTimerEarly:[PacketTimer] = [PacketTimer]()
    static var packetCounterEarly:[Int:Int] = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
    static var gameTimerLate:[PacketTimer] = [PacketTimer]()
    static var packetCounterLate:[Int:Int] = [164:0, 174:0, 190:0, 206:0]
    static var isProbablyGame:Bool = false
    
    static var inGameTimer:[PacketTimer] = [PacketTimer]()
    
    override class func start() {
        super.start()
        detector = self
        dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
            PacketParser.start_loop(self.dotaFilter)
        })
    }
    
    override class func reset(){
        super.reset()
        resetQueueTimer()
        resetGameTimer()
    }
    
    class func resetQueueTimer(){
        queueTimer = [PacketTimer]()
        queueCounter = [78:0, 158:0, 270:0, 285:0]
        queuePort = -1
        stopQueueTimer = [PacketTimer]()
        stopQueueCounter = [78: 0, 250:0, 1300: 0]
    }
    
    class func resetGameTimer(){
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [600:0, 700:0, 800:0, 900:0, 1000:0, 1100:0, 1200:0, 1300:0]
        gameTimerLate = [PacketTimer]()
        packetCounterLate = [164:0, 174:0, 190:0, 206:0]
        inGameTimer = [PacketTimer]()
        isProbablyGame = false
    }
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch MasterController.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            if(startedQueueing(newPacket, timeSpan: 30, maxPacket:0, packetNumber: 2)){MasterController.updateStatus(Status.InQueue)}
            break
            
        case Status.InQueue:
            var gameLate:Bool = isGameLate(newPacket, timeSpan: 10, maxPacket: 5, packetNumber: 6)
            var gameEarly:Bool = isGameEarly(newPacket, timeSpan: 9, maxPacket: 99, packetNumber: 3)
            var stillQueueing:Bool = isStillQueueing(newPacket, timeSpan: 30, maxPacket: 5, packetNumber: 2)
            
            if(gameLate || gameEarly){
                MasterController.updateStatus(Status.GameReady)
                resetQueueTimer()
            }
            else if(!stillQueueing){
                MasterController.updateStatus(Status.InLobby)
                resetQueueTimer()
            }
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
        
        println(queueCounter)
        if(queueCounter[78] > 0 && queueCounter[158] > 0
            || queueTimer.count > 1 && (queueCounter[270] > 0 || queueCounter[285] > 0 )){
                queuePort = p.srcPort
                queueTimer.insert(PacketTimer(key: 158, time: p.captureTime),atIndex: 0)
                var oldCount:Int = queueCounter[158]!
                queueCounter.updateValue(oldCount + 1, forKey: 158)
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
        
        println(stopQueueCounter)
        if(stopQueueCounter[78] > 1 && stopQueueCounter[250] > 0 && !isProbablyGame){return false}
        else if(queueCounter[78] > 0 && queueCounter[158] > 0 || isProbablyGame){return true}
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
        
        if(gameTimerEarly.count > 0 || gameTimerLate.count > 0 && p.packetLength > 1300){isProbablyGame = true}
        else{isProbablyGame = false}
        
        //println(packetCounterEarly)
        if(gameTimerEarly.count >= packetNumber
            && packetCounterEarly[1300] < 2
            && gameTimerLate.count > 0)
        {return true}
            
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
        
        // println(packetCounterLate)
        if((packetCounterLate[164] > 0 || packetCounterLate[174] > 0)
            && packetCounterLate[190] > 0
            && packetCounterLate[206] > 0)
        {return true}
        else if(gameTimerLate.count >= packetNumber){return true}
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