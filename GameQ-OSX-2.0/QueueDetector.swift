//
//  QueueDetector.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

protocol QueueDetector {
    
    static var status:Status{get set}
    
    static func startDetection() -> Bool
    
    static func stopDetection() -> Bool
    
    static func updateStatus(newStatus: Status) -> Bool
    
    static func reset()
    
    static func saveCapture()
    
    //vafan
}

