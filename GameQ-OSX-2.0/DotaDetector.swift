//
//  Capture.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:QueueDetector {
    
    static var status:Status = Status.InLobby
    static let dotaFilter:String = "udp src portrange 27000-27030 or udp dst port 27005 or udp src port 4380"
    static let capSize:Int = 300
    
    
    static func reset() {
        status = Status.InLobby
    }
    
    static func startDetection() -> Bool{
        DotaReader.start(dotaFilter, capSize: capSize, handler: DotaReader.self)
        return true
    }
    
    static func stopDetection() -> Bool{
        DotaReader.stop()
        return true
    }
    
    static func updateStatus(newStatus: Status) -> Bool{
    
        self.status = newStatus
        println(newStatus.rawValue)
        return true;
    }
    
}










