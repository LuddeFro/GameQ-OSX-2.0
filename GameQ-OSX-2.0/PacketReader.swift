//
//  Capture.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketReader:NSObject {
    
    
    
    var packetQueue:[Packet] = [Packet]()
    var queuePointer:Int = 0
    var queueMaxSize:Int = 400
    
    class func addPacketToQueue(packet:Packet) {
        
    }
    
    
    
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int, hlen:Int) {
        println("s: \(srcPort) d: \(dstPort) ip: \(iplen) h: \(hlen)")
        var aPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
    }
    
    
    /**
    description:
    input: 
    output:
    */
    class func start() {
        println("start loop")
        dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
            PacketParser.start_loop()
        })
        //NSThread.detachNewThreadSelector(Selector("start_loop"), toTarget: PacketParser.self, withObject: nil)
        //PacketParser.start_loop()
        println("loop started")
    }
    
        
    
    /**
    description:
    input:
    output:
    */
    class func stop() {
        
    }
    
    
    
}










