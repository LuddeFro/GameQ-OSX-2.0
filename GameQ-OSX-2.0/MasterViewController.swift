//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    @IBOutlet weak var timer: Timer!
    
    @IBOutlet weak var countDown: NSTextField!
    
    @IBOutlet weak var queueTimer: QueueTimer!
    
    @IBOutlet weak var gameStatus: NSTextField!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBAction func startButtonPressed(sender: NSButton) {
        MasterController.startDetection()
    }
    
    @IBAction func capButtonPressed(sender: NSButton) {
        MasterController.saveCapture()
    }
    
    @IBAction func capFailButtonPressed(sender: NSButton) {
        MasterController.saveMissedCapture()
    }
    
    @IBAction func failModePressed(sender: NSButton) {
        MasterController.failMode()
    }
    
    @IBAction func stopButtonPressed(sender: NSButton) {
        MasterController.stopDetection()
    }
    
    
    @IBAction func quitButtonPressed(sender: NSButton) {
        MasterController.stopDetection()
        MasterController.updateStatus(Status.Offline)
        NSApplication.sharedApplication().terminate(self)
    }
    
    var countDownTimer = NSTimer()
    var counter: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getStatus:"), name:"updateStatus", object: nil)
        
        MasterController.start()
        
        self.gameStatus.stringValue = MasterController.game.rawValue
        self.statusLabel.stringValue = MasterController.status.rawValue
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getStatus(sender: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.gameStatus.stringValue = MasterController.game.rawValue
            self.statusLabel.stringValue = MasterController.status.rawValue
            
            switch MasterController.status {
                
            case Status.Offline:
                self.queueTimer.isGame = false
                self.queueTimer.reset()
                self.resetTimer(false)
                self.timer.progress = 0
                break
                
            case Status.Online:
                self.queueTimer.isGame = false
                self.queueTimer.reset()
                self.resetTimer(false)
                self.timer.progress = 0
                break
                
            case Status.InLobby:
                self.queueTimer.isGame = false
                self.queueTimer.reset()
                self.resetTimer(false)
                self.timer.progress = 0
                break
                
            case Status.InQueue:
                self.queueTimer.start()
                self.timer.progress = 0
                break
                
            case Status.GameReady:
                self.queueTimer.isGame = true
                self.queueTimer.reset()
                self.startTimer()
                break
                
            case Status.InGame:
                self.queueTimer.isGame = true
                self.queueTimer.reset()
                self.resetTimer(true)
                break
                
            default:
            break
            }
        }
    }
    
    func startTimer(){
        dispatch_async(dispatch_get_main_queue()) {
            self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update2"), userInfo: nil, repeats: true)
        }
    }
    
    func resetTimer(isGame: Bool){
        if(isGame){
            timer.progress = 1
            countDown.stringValue = "Enjoy!"
        }
        else{
            timer.progress = 0
            countDown.stringValue = ""
        }
        countDownTimer.invalidate()
    }
    
    func update2() {
        counter = counter + 0.1
        self.timer.progress = CGFloat(counter / Float(MasterController.countDownLength))
        var time:Int = Int(Float(MasterController.countDownLength) - counter)
        self.countDown.stringValue = String(time)
        
        if(counter > Float(MasterController.countDownLength)) {
            countDownTimer.invalidate()
            counter = 0
        }
    }
}
