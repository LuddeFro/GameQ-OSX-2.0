//
//  Packet.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

struct Packet {
    let dstPort:Int
    let srcPort:Int
    let packetLength:Int
    let captureTime:Double = NSProcessInfo.processInfo().systemUptime
    
    init(dstPort:Int, srcPort:Int, packetLength:Int) {
        self.dstPort = dstPort
        self.srcPort = srcPort
        self.packetLength = packetLength
        println("capTime: \(captureTime)")
    }
}