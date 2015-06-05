//
//  PacketDetector.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketDetector:GameDetector {
    
    static var detector:PacketDetector.Type = PacketDetector.self
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    
    struct PacketTimer {
        var key:Int = -1
        var time:Double = -1
    }
    
    override class func start() {
        isCapturing = true
    }
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int){
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        detector.updateStatus(newPacket);
    }
    
    class func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double) {
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
    
    override class func reset(){
    packetQueue = [Packet]()}
    
    class func updateStatus(newPacket: Packet) {}
    
    override class func save(){
        DataHandler.logPackets(packetQueue)
        reset()
    }
    
    override class func stop() {
        if(isCapturing){
            PacketParser.stop_loop()
            isCapturing = false
        }
        reset()
    }
}