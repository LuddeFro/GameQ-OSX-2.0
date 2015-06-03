//
//  Capture.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DotaDetector:QueueDetector {
    
    static var running:Bool = false
    static var status:Status = Status.InLobby
    static let dotaFilter:String = "udp src portrange 27000-27030 or udp dst port 27005 or udp src port 4380"
    
    static func reset() {
        status = Status.InLobby
        running = false
        DotaReader.reset()
    }
    
    static func startDetection() -> Bool{
        if(running){
            return false
        }
        else{
            println("Starting Dota Detection")
            DataHandler.game = "dota"
            DotaReader.start(dotaFilter, handler: DotaReader.self)
            running = true
            return true
        }
    }
    
    static func stopDetection() -> Bool{
        if(running){
            println("Stopping Detection")
            DotaReader.stop()
            reset()
            DataHandler.game = ""
            return true
        }
        else{
            return false
        }
    }
    
    static func updateStatus(newStatus: Status) -> Bool{
        
        if(running){
    
            self.status = newStatus
            println(newStatus.rawValue)
            
            if(newStatus == Status.GameReady){
                DotaDetector.saveCapture()
                DotaDetector.stopDetection()}
            return true
        }
        else{
            return false
        }
    }
    
    static func saveCapture() {
        if(running){
            println("Saving File")
        DotaReader.save()
        }
    }
}










