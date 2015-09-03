
//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    @IBOutlet weak var changePWButton: NSButton!
    @IBOutlet weak var toServerButton: NSButton!
    @IBOutlet weak var toDesktopButton: NSButton!
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var feedbackButton: NSButton!
    @IBOutlet weak var missedQueueButton: NSButton!
    @IBOutlet weak var timer: Timer!
    @IBOutlet weak var countDown: NSTextField!
    @IBOutlet weak var queueTimer: QueueTimer!
    @IBOutlet weak var gameStatus: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var saveMissButton: NSButton!
    @IBOutlet weak var saveCapButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var failmodebutton: NSButton!
    
    @IBAction func serverPressed(sender: AnyObject) {
        if(GameDetector.detector.saveToServer){
            GameDetector.detector.saveToServer = false
            toServerButton.title = "toserver = off"
        }
        else{
            GameDetector.detector.saveToServer = true
            toServerButton.title = "toserver = on"
        }
    }
    @IBAction func desktopPressed(sender: AnyObject) {
        if(GameDetector.detector.saveToDesktop){
            GameDetector.detector.saveToDesktop = false
            toDesktopButton.title = "toDesktop = off"
        }
        else{
            GameDetector.detector.saveToDesktop = true
            toDesktopButton.title = "toDesktop = on"
        }
    }
    @IBAction func saveMissedPressed(sender: AnyObject) {
        GameDetector.detector.saveMissedDetection()
    }
    
   func logOut(sender: NSNotification) {
        disableAllButtons()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.performSegueWithIdentifier("MasterToLogin", sender: nil)
        }
    
    @IBAction func startButtonPressed(sender: NSButton) {
        ConnectionHandler.setStatus(Encoding.getIntFromGame(Game.CSGO), status: Encoding.getIntFromStatus(Status.InQueue), finalCallBack:{ (success:Bool, err:String?) in
            if(success){println("succesfully updated status")}})
//        GameDetector.detector.updateStatus(Status.GameReady)
    }
    @IBAction func capButtonPressed(sender: NSButton) {
         GameDetector.detector.updateStatus(Status.InGame)
    }
    @IBAction func capFailButtonPressed(sender: NSButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MasterToReport", sender: nil)
        }}
    @IBAction func failModePressed(sender: NSButton) {
        GameDetector.detector.failMode()
        if(GameDetector.detector.isFailMode){
        failmodebutton.title = "FailMode On"
        }
        
        else{ failmodebutton.title = "FailMode Off" }
    }
    @IBAction func stopButtonPressed(sender: NSButton) {
        ConnectionHandler.setStatus(Encoding.getIntFromGame(Game.NoGame), status: Encoding.getIntFromStatus(Status.Online), finalCallBack:{ (success:Bool, err:String?) in
            if(success){println("succesfully updated status")}})
    }
    @IBAction func quitButtonPressed(sender: NSButton) {
        GameDetector.detector.stopDetection()
        GameDetector.detector.updateStatus(Status.Offline)
        NSApplication.sharedApplication().terminate(self)
    }
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    var countDownTimer = NSTimer()
    var counter: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if((ConnectionHandler.loadEmail() == "fabian.wikstrom@gmail.com")){
            failmodebutton.enabled = true
            failmodebutton.hidden = false
            
            toServerButton.enabled = true
            toServerButton.hidden = false
            serverPressed(self)
        
            toDesktopButton.enabled = true
            toDesktopButton.hidden = false
            desktopPressed(self)
            
            startButton.enabled = true
            startButton.hidden = false
            
            stopButton.enabled = true
            stopButton.hidden = false
            
            saveCapButton.enabled = true
            saveCapButton.hidden = false
            
            saveMissButton.enabled = true
            saveMissButton.hidden = false
            
            quitButton.enabled = true
            quitButton.hidden = false
        }
    }
    

    override func viewWillAppear() {
        super.viewWillAppear()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getStatus:"), name:"updateStatus", object: nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("logOut:"), name:"logOut", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("updateStatus", object: nil)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        //NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getStatus(sender: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.appDelegate.gameItem.title = Encoding.getStringFromGame(GameDetector.detector.game)
            self.appDelegate.statusItem.title = Encoding.getStringFromGameStatus(GameDetector.detector.game,status: GameDetector.detector.status)
            
            self.gameStatus.stringValue = Encoding.getStringFromGame(GameDetector.detector.game)
            self.statusLabel.stringValue = Encoding.getStringFromGameStatus(GameDetector.detector.game, status: GameDetector.detector.status)
            
            switch GameDetector.status {
                
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
                self.queueTimer.start()
                self.timer.progress = 0
                break
                
            case Status.InQueue:
                self.queueTimer.isGame = false
                self.queueTimer.reset()
                self.resetTimer(false)
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
            self.counter = max(0, Float(GameDetector.counter - 1))
            self.countDownTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update2"), userInfo: nil, repeats: true)
        }
    }
    
    func resetTimer(isGame: Bool){
        dispatch_async(dispatch_get_main_queue()) {
            if(isGame){
                self.timer.progress = 1
                self.countDown.stringValue = "Enjoy!"
            }
            else{
                self.timer.progress = 0
                self.countDown.stringValue = ""
            }
            self.countDownTimer.invalidate()
            self.countDownTimer = NSTimer()
            self.counter = 0
        }
    }
    
    func update2() {
        dispatch_async(dispatch_get_main_queue()) {
            self.counter = self.counter + 0.1
            self.timer.progress = CGFloat(self.counter / Float(GameDetector.countDownLength))
            var time:Int = Int(Float(GameDetector.countDownLength) - self.counter)
            self.countDown.stringValue = String(time)
            
            if(self.counter > Float(GameDetector.countDownLength)) {
                self.countDownTimer.invalidate()
                self.counter = 0
            }
        }
    }
    
    private func disableAllButtons(){
        settingsButton.enabled = false
        feedbackButton.enabled = false
        changePWButton.enabled = false
    }
    private func enableAllButtons(){
        changePWButton.enabled = true
        settingsButton.enabled = true
        feedbackButton.enabled = true
    }
}
