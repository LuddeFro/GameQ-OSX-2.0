//
//  HoNReader.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class HoNReader:PacketReader{
    
    static var gameTimer:[PacketTimer] = [PacketTimer]()
    
    override class func handle(srcPort:Int, dstPort:Int, iplen:Int) {
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        updateStatus(newPacket);
    }
    
    class func handle2(srcPort:Int, dstPort:Int, iplen:Int, time:Double) {
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
    
    class func updateStatus(newPacket:Packet){
        
        addPacketToQueue(newPacket)
        
        switch HoNDetector.status{
            
        case Status.Offline:
            break
            
        case Status.Online:
            break
            
        case Status.InLobby:
            
            if(isGame(newPacket, timeSpan: 5, maxPacket: 0, packetNumber: 10)){
             HoNDetector.updateStatus(Status.GameReady)
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
        
        //     println(packetCounter)
        if(gameTimer.count >= packetNumber){return true}
        else {return false}
    }
}