//
//  HoNReader.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class HoNDetector:PacketDetector{
    
    static let honFilter:String = "udp src portrange 11235-11335"
    static var gameTimer:[PacketTimer] = [PacketTimer]()
    
    override class func start() {
        super.start()
        detector = self
        dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
            PacketParser.start_loop(self.honFilter)
        })
    }
    

    override class func reset(){
        gameTimer = [PacketTimer]()
    }
    
    
    override class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch MasterController.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            
            if(isGame(newPacket, timeSpan: 5, maxPacket: 0, packetNumber: 10)){
             MasterController.updateStatus(Status.GameReady)
            }
            
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
            gameTimer.removeLast().key
        }
        
        gameTimer.insert(PacketTimer(key: p.srcPort, time: p.captureTime),atIndex: 0)
        
        if(gameTimer.count >= packetNumber){return true}
        else {return false}
    }
}