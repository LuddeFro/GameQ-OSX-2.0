
//
//  CSGODetector.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/6/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

//
//  HoNReader.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class CSGODetector:PacketDetector{
    
    static let csgoFilter:String = "udp src portrange 27000-28000 or udp dst portrange 27000-28000 or udp dst port 27005 or udp src port 27015 or udp src port 27005 or udp dst port 27015"
    
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
    static var timer = NSTimer()
    
    override class func start() {
        detector = self
        if(!isCapturing){
            dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
                self.packetParser.start_loop(self.csgoFilter)
            })
        }
        super.start()
    }
    
    
    override class func reset(){
        super.reset()
        foundServer = false
        soonGame = false
        
        gameTimerEarly = [PacketTimer]()
        packetCounterEarly = [170:0]
        
        gameTimerLate = [PacketTimer]()
        packetCounterLate = [60:0, 590:0]
        
        dstGameTimer = [PacketTimer]()
        dstPacketCounter = [75:0]
        
        timer.invalidate()
        time = -1
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
        
        timer.invalidate()
        time = -1
    }
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        
        //IN LOBBY
        if(MasterController.status == Status.InLobby){
            
            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:90)
            var gameReady:Bool = isGameReady(newPacket)
            
            if(inGame){MasterController.updateStatus(Status.InGame)}
            else if(gameReady){MasterController.updateStatus(Status.GameReady)
                resetGameTimer()}
        }
            
            //IN QUEUE
        else  if(MasterController.status == Status.InQueue){
            
        }
            
            //GAME READY
        else if(MasterController.status == Status.GameReady){
            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:90)
            if(inGame){MasterController.updateStatus(Status.InGame)}
        }
            
            //IN GAME
        else  if(MasterController.status == Status.InGame){
            var inGame = isGame(newPacket, timeSpan:10, maxPacket:0, packetNumber:90)
            if(!inGame){MasterController.updateStatus(Status.InLobby)}
            
        }
            
        else {
        }
    }
    
    
    class func isGameReady(p:Packet) -> Bool{
        
        while(!gameTimerEarly.isEmpty && p.captureTime - gameTimerEarly.last!.time > 60){
            var key:Int = gameTimerEarly.removeLast().key
            packetCounterEarly[key]! = packetCounterEarly[key]! - 1
        }
        
        var t:Double = -1
        if(MasterController.isTesting){t = 0.5}
        else{t = 2}
        
        while(!gameTimerLate.isEmpty && p.captureTime - gameTimerLate.last!.time > t){
            var key:Int = gameTimerLate.removeLast().key
            packetCounterLate[key]! = packetCounterLate[key]! - 1
        }
        
        while(!dstGameTimer.isEmpty && p.captureTime - dstGameTimer.last!.time > 10){
            var key:Int = dstGameTimer.removeLast().key
            dstPacketCounter[key]! = dstPacketCounter[key]! - 1
        }
        
        
        
        for key in packetCounterEarly.keys{
            if(p.packetLength <= key + 30 && p.packetLength >= key && (p.srcPort == queuePort || queuePort ==
                -1) && p.srcPort <= portMax && p.srcPort >= portMin){
                    gameTimerEarly.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                    packetCounterEarly[key]! =  packetCounterEarly[key]! + 1
            }
        }
        
        for key in packetCounterLate.keys{
            if(p.packetLength <= key && p.packetLength >= key && p.dstPort == 27005) {
                gameTimerLate.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                packetCounterLate[key]! = packetCounterLate[key]! + 1
            }
        }
        
        for key in dstPacketCounter.keys{
            if(p.packetLength <= key && p.packetLength >= key && p.dstPort != 27015){
                dstGameTimer.insert(PacketTimer(key: key, time: p.captureTime),atIndex: 0)
                dstPacketCounter[key]! = dstPacketCounter[key]! + 1
            }
        }
        
        
        if(gameTimerEarly.count >= 30){foundServer = true}
        else{foundServer = false}
        
        if(packetCounterLate[60] > 0 && soonGame == false){
            soonGame = true
            time = p.captureTime
            dispatch_async(dispatch_get_main_queue()) {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("update3"), userInfo: nil, repeats: true)
            }
        }
        
        if(soonGame == true && packetCounterLate[590] > 0){
            soonGame = false
            time = -1
            timer.invalidate()}
        
        println(packetCounterEarly)
        println(packetCounterLate)
        println(dstPacketCounter)
        println(soonGame)
        println(foundServer)
        
        if(soonGame == true && packetCounterLate[60] <= 0 && foundServer == true){return true}
        else{ return false}
    }
    
    
    class func isGame(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!gameTimer.isEmpty && p.captureTime - gameTimer.last!.time > timeSpan || gameTimer.count >= inGameMaxSize){
            gameTimer.removeLast()
        }
        
        gameTimer.insert(PacketTimer(key: p.srcPort, time: p.captureTime),atIndex: 0)
        
        if(gameTimer.count >= packetNumber){return true}
        else {return false}
    }
    
    
    static func update3(){
        if(soonGame == true){
            time = time + 0.2
            if(isGameReady(Packet(dstPort: -1, srcPort: -1, packetLength: -1, time: time))){
                MasterController.updateStatus(Status.GameReady)
                timer.invalidate()
            }
        }
    }
}