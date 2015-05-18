//
//  Capture.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class PacketReader {
    
    
    
    
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










