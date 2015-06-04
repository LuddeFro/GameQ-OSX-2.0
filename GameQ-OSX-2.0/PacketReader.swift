//
//  PacketReader.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketReader:GameDetector {
    
    static var detector:PacketReader.Type = PacketReader.self
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    
    struct PacketTimer {
        var key:Int = -1
        var time:Double = -1
    }
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int){
        detector.handle(srcPort, dstPort: dstPort, iplen: iplen)
    }
    
    class func handleTest(srcPort:Int, dstPort:Int, iplen:Int){
        detector.handleTest(srcPort, dstPort: dstPort, iplen: iplen)
    }
    
    override class func start() {
        isCapturing = true
    }
    
    override class func reset(){}
    
    class func updateStatus(newPacket: Packet) {}
    
    override class func save(){
        DataHandler.logPackets(packetQueue)
        reset()
    }
    
    override class func stop() {
        if(isCapturing){
            PacketParser.stop_loop()
        }
        reset()
    }
}