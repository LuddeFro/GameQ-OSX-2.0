//
//  MasterController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/4/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation
import Cocoa

class GameDetector:NSObject, GameDetectorProtocol {
    
    static var status:Status = Status.Online
    static var game:Game = Game.NoGame
    static var isFailMode:Bool = false
    static var isTesting:Bool = false
    static let dataHandler = DataHandler.sharedInstance
    static var detector:GameDetector.Type = GameDetector.self
    
    static var countDownLength:Int = -1
    static var counter:Int = -1
    static var countDownTimer:NSTimer = NSTimer()
    
    class func startDetection(){
        
        dataHandler.folderName = self.game.rawValue
        counter = 0
    }
    
    class func updateStatus(newStatus: Status){
        
        if(newStatus == Status.InLobby || newStatus == Status.InQueue){
            counter = 0
        }
        
        if(status != newStatus && newStatus == Status.GameReady && !isTesting){
            detector.saveDetection()
            startTimer()
        }
            
        else{
            countDownTimer.invalidate()
            counter = 0
        }
        
        status = newStatus
        println(newStatus.rawValue)
        NSNotificationCenter.defaultCenter().postNotificationName("updateStatus", object: nil)
        
        ConnectionHandler.setStatus(Encoding.getIntFromGame(self.game), status: Encoding.getIntFromStatus(self.status), finalCallBack:{ (success:Bool, err:String?) in
        println("succesfully updated status")
        })
    }
    
    class func saveDetection() {
        println("Saving File")
        dataHandler.folderName = game.rawValue
    }
    
    class func resetDetection() {
        updateStatus(Status.InLobby)
    }
    
    class func saveMissedDetection(){
        println("Saving Missed File")
        dataHandler.folderName = game.rawValue + "missed"
    }
    
    final class func failMode(){
        
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
    
    class func stopDetection(){
        println("Stopping Detection")
        self.game = Game.NoGame
        updateStatus(Status.Online)
        isFailMode = false
        isTesting = false
        counter = -1
        countDownLength = -1
    }
    
    class func getStatusString() -> String {
        
        return self.status.rawValue
    }
    
    static func startTimer(){
        
        dispatch_async(dispatch_get_main_queue()) {
            self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)}
    }
    
    static func update() {
        
        if(status == Status.GameReady){
            counter = counter + 1
        }
        
        if(counter >= countDownLength && status == Status.GameReady){
            counter = 0
            updateStatus(Status.InGame)
            countDownTimer.invalidate()
        }
    }
}