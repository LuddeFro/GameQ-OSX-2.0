//
//  PacketDetector.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

protocol PacketDetector:NSObjectProtocol, GameDetectorProtocol {
    
    static var packetQueue:[Packet] {get set}
    static var queueMaxSize:Int {get set}
    static var isCapturing:Bool {get set}
    static var packetParser:PacketParser {get set}
    
    static func handle(srcPort:Int, dstPort:Int, iplen:Int)
    
    static func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double)
    
    static func update(newPacket: Packet)
}