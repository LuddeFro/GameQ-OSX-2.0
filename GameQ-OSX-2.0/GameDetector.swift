//
//  MasterController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/4/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation
import Cocoa

protocol GameDetectorProtocol : NSObjectProtocol {
    
    static func startDetection()
    static func updateStatus(newStatus: Status)
    static func saveDetection()
    static func saveMissedDetection()
    static func failMode()
    static func resetDetection()
    static func stopDetection()
    static func fileToString() -> String
}

class GameDetector:NSObject, GameDetectorProtocol {

    static var status:Status = Status.Online
    static var game:Game = Game.NoGame
    static var isFailMode:Bool = false
    static var isTesting:Bool = false
    static var testMode:Bool = false
    static let dataHandler = DataHandler.sharedInstance
    static var detector:GameDetector.Type = GameDetector.self
    
    static var countDownLength:Int = -1
    static var counter:Int = -1
    static var countDownTimer:NSTimer = NSTimer()
    
    class func startDetection(){
        dataHandler.folderName = Encoding.getStringFromGame(self.game)
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
        println(Encoding.getStringFromGameStatus(self.game, status: self.status))
        NSNotificationCenter.defaultCenter().postNotificationName("updateStatus", object: nil)
        
        if(isTesting == false && testMode == false){
        ConnectionHandler.setStatus(Encoding.getIntFromGame(self.game), status: Encoding.getIntFromStatus(self.status), finalCallBack:{ (success:Bool, err:String?) in
        println("succesfully updated status")
        })}
    }
    
    class func saveDetection() {
        println("Saving File")
        dataHandler.folderName = Encoding.getStringFromGame(self.game)
    }
    
    class func resetDetection() {
    }
    
    class func saveMissedDetection(){
        println("Saving Missed File")
        dataHandler.folderName =  Encoding.getStringFromGame(self.game) + "missed"
    }
    
    final class func failMode(){
        
        if(isFailMode){
            println("FailMode Off")
            dataHandler.folderName = Encoding.getStringFromGame(self.game)
            isFailMode = false
        }
            
        else{
            println("FailMode On")
            dataHandler.folderName =  Encoding.getStringFromGame(self.game) + "ForcedFails"
            isFailMode = true
        }
    }
    
    class func stopDetection(){
        println("Stopping Detection")
        self.game = Game.NoGame
        detector = GameDetector.self
        updateStatus(Status.Offline)
        isFailMode = false
        isTesting = false
        counter = -1
        countDownLength = -1
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
    
    class func fileToString() -> String {return ""}
}