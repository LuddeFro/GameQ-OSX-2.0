//
//  Parser.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketHandler: NSObject {
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int, hlen:Int) {
        println("s: \(srcPort) d: \(dstPort) ip: \(iplen) h: \(hlen)")
    }
    
}