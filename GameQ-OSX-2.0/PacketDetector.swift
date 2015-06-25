//
//  PacketDetector.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketDetector:GameDetector {
    
    static var packetQueue:[Packet] = [Packet]()
    static var queueMaxSize:Int = 200
    static var isCapturing = false
    static let dataHandler = DataHandler.sharedInstance
    static let packetParser:PacketParser = PacketParser.getSharedInstance()
    
    struct PacketTimer {
        var key:Int = -1
        var time:Double = -1
    }
    
    override class func start() {
        isCapturing = true
    }
    
    class func handle(srcPort:Int, dstPort:Int, iplen:Int){
        println("no real detector used")
    }
    
    class func handleTest(srcPort:Int, dstPort:Int, iplen:Int, time:Double) {
       println("no real detector used")
    }
    
    class func addPacketToQueue(newPacket:Packet) {
        packetQueue.insert(newPacket, atIndex: 0)
        if packetQueue.count >= queueMaxSize {
            packetQueue.removeLast()
        }
    }
    
    override class func reset(){
    packetQueue = [Packet]()}
    
    class func updateStatus(newPacket: Packet) {}
    
    override class func save(){
        dataHandler.logPackets(packetQueue)
    }
    
    override class func stop() {
        if(isCapturing){
            packetParser.stop_loop()
            isCapturing = false
        }
        reset()
    }
}