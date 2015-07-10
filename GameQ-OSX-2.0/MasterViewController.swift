
//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    
    @IBOutlet weak var settingsButton: NSButton!
    @IBOutlet weak var feedbackButton: NSButton!
    @IBOutlet weak var logOutButton: NSButton!
    @IBOutlet weak var missedQueueButton: NSButton!
    @IBOutlet weak var timer: Timer!
    @IBOutlet weak var countDown: NSTextField!
    @IBOutlet weak var queueTimer: QueueTimer!
    @IBOutlet weak var gameStatus: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var saveMissButton: NSButton!
    
    @IBOutlet weak var isTestingButton: NSButton!
    
    @IBOutlet weak var saveCapButton: NSButton!
    
    @IBOutlet weak var startButton: NSButton!
    
    @IBOutlet weak var quitButton: NSButton!
    
    @IBOutlet weak var stopButton: NSButton!
    
    @IBOutlet weak var failmodebutton: NSButton!
    
    @IBAction func isTestingPressed(sender: AnyObject) {
        if(detector.testMode){
            println("testing off")
            detector.testMode = false}
        else{
            println("testing on")
            detector.testMode = true}
    }
    
    @IBAction func saveMissedPressed(sender: AnyObject) {
        detector.saveMissedDetection()
    }
    
    @IBAction func logOutPressed(sender: AnyObject) {
        disableAllButtons()
        self.detector.stopDetection()
        ConnectionHandler.logout({ (success:Bool, err:String?) in
            dispatch_async(dispatch_get_main_queue()) {
                self.appDelegate.didLogOut()
                self.programTimer.invalidate()
                self.dismissController(self)
                NSNotificationCenter.defaultCenter().removeObserver(self)
                self.performSegueWithIdentifier("MasterToLogin", sender: nil)
            }})}
    
    @IBAction func startButtonPressed(sender: NSButton) {
        detector.startDetection()
    }
    
    @IBAction func capButtonPressed(sender: NSButton) {
        detector.saveDetection()
    }
    
    @IBAction func capFailButtonPressed(sender: NSButton) {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MasterToReport", sender: nil)
        }}
    
    @IBAction func failModePressed(sender: NSButton) {
        detector.failMode()
    }
    
    @IBAction func stopButtonPressed(sender: NSButton) {
        detector.stopDetection()
    }
    
    @IBAction func quitButtonPressed(sender: NSButton) {
        detector.stopDetection()
        detector.updateStatus(Status.Offline)
        NSApplication.sharedApplication().terminate(self)
    }
    
    let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
    var countDownTimer = NSTimer()
    var counter: Float = 0
    var detector:GameDetector.Type = GameDetector.self
    var game:Game = Game.NoGame
    var programTimer:NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        programTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        let font = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
        let style = NSMutableParagraphStyle()
        style.alignment = .CenterTextAlignment
        
        logOutButton.attributedTitle = NSAttributedString(string: "Log Out", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        missedQueueButton.attributedTitle = NSAttributedString(string: "Send Feedback", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getStatus:"), name:"updateStatus", object: nil)
        
        self.gameStatus.stringValue =  Encoding.getStringFromGame(self.detector.game)
        self.statusLabel.stringValue = Encoding.getStringFromGameStatus(self.detector.game, status: self.detector.status)
        
        
        if(ConnectionHandler.loadEmail() == "asd@asd.com"){
            failmodebutton.enabled = true
            failmodebutton.hidden = false
            
            isTestingButton.enabled = true
            isTestingButton.hidden = false
            
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
    
    func getStatus(sender: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.appDelegate.gameItem.title = Encoding.getStringFromGame(self.detector.game)
            self.appDelegate.statusItem.title = Encoding.getStringFromGameStatus(self.detector.game,status: self.detector.status)
            self.gameStatus.stringValue = Encoding.getStringFromGame(self.detector.game)
            self.statusLabel.stringValue = Encoding.getStringFromGameStatus(self.detector.game, status: self.detector.status)
            
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
    
    
    //THIS MUST BE MOVED
    func update() {
        
        var ws = NSWorkspace.sharedWorkspace()
        var apps:[NSRunningApplication] = ws.runningApplications as! [NSRunningApplication]
        var activeApps:Set<String> = Set<String>()
        var newGame:Game = Game.NoGame
        
        for app in apps {
            var appName:String? = app.localizedName
            if(appName != nil){activeApps.insert(appName!)}
        }
        
        if(activeApps.contains("dota_osx") || activeApps.contains("dota2")){
            detector = DotaDetector.self
            newGame = Game.Dota2
        }
            
        else if(activeApps.contains("csgo_osx")){
            detector = CSGODetector.self
            newGame = Game.CSGO
        }
            
        else if(activeApps.contains("Heroes")){
            detector = HOTSDetector.self
            newGame = Game.HOTS
        }
            
        else if(activeApps.contains("Heroes of Newerth")){
            detector = HoNDetector.self
            newGame = Game.HoN
        }
            
        else if(activeApps.contains("LolClient")){
            detector = LoLDetector.self
            newGame = Game.LoL
        }
            
        else {newGame = Game.NoGame}
        
        if(game != newGame && newGame != Game.NoGame){
            detector.startDetection()
            game = newGame
        }
            
        else if(game != newGame && newGame == Game.NoGame) {
            detector.stopDetection()
            game = newGame
        }
        
        
        //Lol Specific shit
        if((detector.game == Game.LoL) && (detector.status == Status.InGame) && (activeApps.contains("League Of Legends") == false)){
            detector.updateStatus(Status.InLobby)
        }
            
        else if((detector.game == Game.LoL) && (detector.status != Status.InGame) && activeApps.contains("League Of Legends")){
            LoLDetector.updateStatus(Status.InGame)
        }
    }
    
    func startTimer(){
        println("fan händer")
        dispatch_async(dispatch_get_main_queue()) {
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
        logOutButton.enabled = false
        settingsButton.enabled = false
        feedbackButton.enabled = false
    }
    
    private func enableAllButtons(){
        logOutButton.enabled = true
        settingsButton.enabled = true
        feedbackButton.enabled = true
    }
}
