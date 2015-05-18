//
//  Packet.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class Packet:NSObject {
    
    let dstPort:Int
    let srcPort:Int
    let packetLength:Int
    let captureTime:CGFloat
    
    init(dstPort:Int, srcPort:Int, packetLength:Int, captureTime:CGFloat) {
        self.dstPort = dstPort
        self.srcPort = srcPort
        self.packetLength = packetLength
        self.captureTime = captureTime
        super.init()
    }
}