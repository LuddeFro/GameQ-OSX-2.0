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
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int){
        handler.handle(srcPort, dstPort: dstPort, iplen: iplen)
    }
    
    
    class func start(filter:String, capSize:Int, handler:PacketReader.Type) {
        self.handler = handler
        dispatch_async(dispatch_queue_create("io.gameq.osx.pcap", nil), {
            PacketParser.start_loop(filter)
        })
    }
    
    class func reset(){}
  
    class func save(){}
    
    class func stop() {
        PacketParser.stop_loop()
        reset()
    }
}