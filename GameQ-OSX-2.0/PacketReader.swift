//
//  Capture.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketReader {
    
    
    struct Static {
        static let filter:UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>("".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.bytes)
        static let snapLength:Int32 = 64 // length to be caught
        static let snapNum:Int32 = 0 // number of packets to be caught
        static var errbuf:UnsafeMutablePointer<Int8> = UnsafeMutablePointer<Int8>()
        
        static var userChar:UnsafeMutablePointer<u_char> = UnsafeMutablePointer<u_char>()
        
    }
    
    
    /**
    description:
    input: 
    output:
    */
    class func start() {
        
        
        
        println("start loop")
        //NSThread.detachNewThreadSelector(Selector("start_loop"), toTarget: PacketParser.self, withObject: nil)
        PacketParser.start_loop()
        println("loop started")
    }
    
        
    
    /**
    description:
    input:
    output:
    */
    class func stop() {
        
    }
    
    
    
}










