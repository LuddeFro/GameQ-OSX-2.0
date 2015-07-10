//
//  PacketDetector.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

protocol PacketDetectorProtocol:NSObjectProtocol, GameDetectorProtocol {
    
    static var packetQueue:[Packet] {get set}
    static var queueMaxSize:Int {get set}
    static var isCapturing:Bool {get set}
    static var packetParser:PacketParser {get set}
    static func handle(srcPort:Int, dstPort:Int, iplen:Int)
    static func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double)
    static func update(newPacket: Packet)
}

class PacketDetector: GameDetector, PacketDetectorProtocol{
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    static var packetParser:PacketParser = PacketParser.getSharedInstance()
    
    static func handle(srcPort:Int, dstPort:Int, iplen:Int){
        
        if(iplen > 5){
            var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen)
            println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
            
            if(detector.status != Status.InGame){
                packetQueue.insert(newPacket, atIndex: 0)
                if packetQueue.count >= queueMaxSize {
                    packetQueue.removeLast()
                }
            }
            update(newPacket);
        }
    }
    
    static func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double) {
        var newPacket:Packet = Packet(dstPort: dstPort, srcPort: srcPort, packetLength: iplen, time: time)
        println("s: \(newPacket.srcPort) d: \(newPacket.dstPort) ip: \(newPacket.packetLength) time: \(newPacket.captureTime)")
        update(newPacket);
    }
    
    class func update(newPacket: Packet){}
    
    override class func fileToString() -> String{
        var log:String = ""
        for i in 0..<packetQueue.count {
            log = "\(log)\(packetQueue[i].srcPort),\(packetQueue[i].dstPort),\(packetQueue[i].captureTime),\(packetQueue[i].packetLength)\n"
        }
        return log
    }
    
    override class func saveDetection(){
        super.saveDetection()
        packetQueue = [Packet]()
    }
    
    override class func saveMissedDetection(){
        super.saveMissedDetection()
        packetQueue = [Packet]()
    }
}