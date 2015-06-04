//
//  PacketReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketReader:NSObject{
    
    static var handler:PacketReader.Type = PacketReader.self
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    
    struct PacketTimer {
        var key:Int = -1
        var time:Double = -1
    }
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int){
        handler.handle(srcPort, dstPort: dstPort, iplen: iplen)
    }
    
    class func start(handler:PacketReader.Type) {
        self.handler = handler
        isCapturing = true
        }
    
    class func reset(){}
    
    class func save(){
        DataHandler.logPackets(packetQueue)
        reset()
    }
    
    class func stop() {
        if(isCapturing){
        PacketParser.stop_loop()
        }
        reset()
    }
}