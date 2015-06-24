//
//  MasterController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/4/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation
import Cocoa

class MasterController:NSObject {
    
    static var status:Status = Status.Online
    static var game:Game = Game.NoGame
    static var detector:GameDetector.Type = GameDetector.self
    static var isFailMode:Bool = false
    static var isTesting:Bool = false
    static let dataHandler = DataHandler.sharedInstance
    static var countDownLength:Int = -1
    static var counter:Int = 0
    
    static func updateGame(game:Game){
        self.game = game
        dataHandler.folderName = game.rawValue
        
        switch self.game{
            
        case Game.Dota:
            println("Setting up Dota Detection")
            detector = DotaDetector.self
            self.status = Status.InLobby
            countDownLength = 45
            startDetection()
            break
        case Game.HoN:
            println("Setting up HoN Detection")
            detector = HoNDetector.self
            self.status = Status.InLobby
            startDetection()
            break
        case Game.CSGO:
            println("Setting up CSGO Detection")
            detector = CSGODetector.self
            self.status = Status.InLobby
            countDownLength = 20
            startDetection()
        case Game.NoGame:
            println("No game Active")
            self.status = Status.Online
            startDetection()
            break
        default:
            break
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateStatus", object: nil)
    }
    
    static func startDetection(){
        if(game != Game.NoGame){
            println("Starting " + game.rawValue + " Detection")
            detector.start()
        }
    }
    
    static func updateStatus(newStatus: Status){
        
        if(status != newStatus && newStatus == Status.GameReady && !isTesting){detector.save()}
        
        status = newStatus
        println(newStatus.rawValue)
        NSNotificationCenter.defaultCenter().postNotificationName("updateStatus", object: nil)
    }
    
    static func stopDetection(){
        if(game != Game.NoGame){
            println("Stopping " + game.rawValue + " Detection")
            reset()
            detector.stop()
        }
    }
    
    static func reset() {
        updateStatus(Status.InLobby)
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
    
    static func start(){
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    static func update() {
        
        if(status == Status.GameReady){
            counter = counter + 1
        }
        
        if(counter >= countDownLength && status == Status.GameReady){
            counter = 0
            updateStatus(Status.InGame)
        }
        
        var ws = NSWorkspace.sharedWorkspace()
        var apps:[NSRunningApplication] = ws.runningApplications as! [NSRunningApplication]
        var activeApps:Set<String> = Set<String>()
        var currentGame:Game = Game.NoGame
        
        for app in apps {
            var appName:String? = app.localizedName
            if(appName != nil){activeApps.insert(appName!)}
        }
        
        if(activeApps.contains("dota_osx")){
            currentGame = Game.Dota
        }
            
        else if(activeApps.contains("csgo_osx")){
            currentGame = Game.CSGO
        }
        
        else {currentGame = Game.NoGame}
        
        if(self.game != currentGame){
            updateGame(currentGame)
        }
    }

}