////
////  HoNDetector.swift
////  GameQ-OSX-2.0
////
////  Created by Fabian Wikström on 6/2/15.
////  Copyright (c) 2015 GameQ AB. All rights reserved.
////
//
//import Foundation
//
//class HoNDetector:QueueDetector {
//    
//    static var running:Bool = false
//    static var status:Status = Status.InLobby
//    static let honFilter:String = "udp src portrange 11235-11335"
//    
//    static func reset() {
//        status = Status.InLobby
//        running = false
//        HoNReader.reset()
//    }
//    
//    static func startDetection() -> Bool{
//        if(running){
//            return false
//        }
//        else{
//            println("Starting HoN Detection")
//            HoNReader.start(HoNReader.self)
//            running = true
//            return true
//        }
//    }
//    
//    static func stopDetection() -> Bool{
//        if(running){
//             println("Stopped Detection")
//            HoNReader.stop()
//            reset()
//            return true
//        }
//        else{
//            return false
//        }
//    }
//    
//    static func updateStatus(newStatus: Status) -> Bool{
//        
//        if(running){
//            self.status = newStatus
//            println(newStatus.rawValue)
//            return true
//        }
//        else{
//            return false
//        }
//    }
//    
//    static func saveCapture() {
//        if(running){
//            HoNReader.save()
//        }
//    }
//}