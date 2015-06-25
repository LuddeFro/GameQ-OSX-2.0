//
//  GameDetector.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/4/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

protocol GameDetectorProtocol : NSObjectProtocol {
    
    static func startDetection()
    
    static func updateStatus(newStatus: Status)
    
    static func saveDetection()
    
    static func saveMissedDetection()
    
    static func failMode()
    
    static func resetDetection()
    
    static func stopDetection()
}