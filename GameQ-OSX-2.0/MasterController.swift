//
//  MasterController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/4/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class MasterController:NSObject {
    
    static var status:Status = Status.Offline
    static var game:Game = Game.NoGame
    static var detector:GameDetector.Type = GameDetector.self
    static var isFailMode:Bool = false
    static var isTesting:Bool = false
    static let dataHandler = DataHandler.sharedInstance
    
    static func gameDetection(game:Game){
        self.game = game
        self.status = Status.InLobby
        dataHandler.folderName = game.rawValue
        
        switch self.game{
            
        case Game.Dota:
            println("Setting up Dota Detection")
            detector = DotaDetector.self
            break
        case Game.HoN:
            println("Setting up HoN Detection")
            detector = HoNDetector.self
            break
        case Game.CSGO:
            println("Setting up CSGO Detection")
            detector = CSGODetector.self
        default:
            break
        }
    }
    
    static func startDetection(){
        if(game != Game.NoGame){
        println("Starting " + game.rawValue + " Detection")
        detector.start()
        }
    }
    
    static func updateStatus(newStatus: Status){
        
        if(game != Game.NoGame){
            
            self.status = newStatus
            println(newStatus.rawValue)
            
            if(newStatus == Status.GameReady && isTesting == false){
                saveCapture()
            }
        }
    }
    
    static func stopDetection(){
        if(game != Game.NoGame){
            println("Stopping " + game.rawValue + " Detection")
            reset()
            detector.stop()
        }
    }
    
    static func reset() {
        status = Status.InLobby
        detector.reset()
    }
    
    static func saveCapture() {
        if(game != Game.NoGame){
            println("Saving File")
            detector.save()
        }
    }
    
    static func saveMissedCapture(){
        if(game != Game.NoGame){
            println("Saving Missed File")
            dataHandler.folderName = game.rawValue + "missed"
            detector.save()
        }
    }
    
    static func failMode(){
    
        if(isFailMode){
            println("FailMode Off")
            dataHandler.folderName = game.rawValue
            isFailMode = false
        }
        
        else{
            println("FailMode On")
            dataHandler.folderName = game.rawValue + "ForcedFails"
            isFailMode = true
        }
    }
}