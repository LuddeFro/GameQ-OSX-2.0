
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
    
    static let csgoFilter:String = "(udp src portrange 27000-28000 and udp dst portrange 27000-27050) or udp dst port 27005 or udp dst port 51840"

    static var gameTimer:[PacketTimer] = [PacketTimer]()
    
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
    }
    
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch MasterController.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            
            break
        case Status.InQueue:
            
            break
            
        case Status.GameReady:
            break
            
        case Status.InGame:
            break
        }
    }
    
    class func isGame(p:Packet, timeSpan:Double, maxPacket:Int, packetNumber:Int) -> Bool{
        
        while(!gameTimer.isEmpty && p.captureTime - gameTimer.last!.time > timeSpan){
            gameTimer.removeLast()
        }
        
        gameTimer.insert(PacketTimer(key: p.srcPort, time: p.captureTime),atIndex: 0)
        
        if(gameTimer.count >= packetNumber){return true}
        else {return false}
    }
}