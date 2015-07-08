
//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    @IBAction func logOutPressed(sender: AnyObject) {
        
        ConnectionHandler.logout({ (success:Bool, err:String?) in
            dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MasterToLogin", sender: nil)
            }
        })
    }
    
    
    @IBOutlet weak var logOutButton: NSButton!
    
    @IBOutlet weak var missedQueueButton: NSButton!
    @IBOutlet weak var timer: Timer!
    
    @IBOutlet weak var countDown: NSTextField!
    
    @IBOutlet weak var queueTimer: QueueTimer!
    
    @IBOutlet weak var gameStatus: NSTextField!
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBAction func startButtonPressed(sender: NSButton) {
        detector.startDetection()
    }
    
    @IBAction func capButtonPressed(sender: NSButton) {
        detector.saveDetection()
    }
    
    @IBAction func capFailButtonPressed(sender: NSButton) {

        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MasterToReport", sender: nil)
        }
    }
    
    @IBAction func failModePressed(sender: NSButton) {
        detector.failMode()
        detector.startTimer()
    }
    
    @IBAction func stopButtonPressed(sender: NSButton) {
        detector.stopDetection()
    }
    
    
    @IBAction func quitButtonPressed(sender: NSButton) {
        detector.stopDetection()
        detector.updateStatus(Status.Offline)
        NSApplication.sharedApplication().terminate(self)
    }
    
    var countDownTimer = NSTimer()
    var counter: Float = 0
    var detector:GameDetector.Type = GameDetector.self
    var game:Game = Game.NoGame
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
        let style = NSMutableParagraphStyle()
        style.alignment = .CenterTextAlignment
        
        logOutButton.attributedTitle = NSAttributedString(string: "Log Out", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        missedQueueButton.attributedTitle = NSAttributedString(string: "Send Feedback", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getStatus:"), name:"updateStatus", object: nil)
        
        self.gameStatus.stringValue = GameDetector.game.rawValue
        self.statusLabel.stringValue = GameDetector.status.rawValue
        var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getStatus(sender: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.gameStatus.stringValue = self.detector.game.rawValue
            self.statusLabel.stringValue = self.detector.getStatusString()
            
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
    
    func update() {
        
        var ws = NSWorkspace.sharedWorkspace()
        var apps:[NSRunningApplication] = ws.runningApplications as! [NSRunningApplication]
        var activeApps:Set<String> = Set<String>()
        var newGame:Game = Game.NoGame
        
        for app in apps {
            var appName:String? = app.localizedName
            if(appName != nil){activeApps.insert(appName!)}
        }
        
        if(activeApps.contains("dota_osx")){
            detector = DotaDetector.self
            newGame = Game.Dota
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
        
        if((detector.game == Game.LoL) && (detector.status == Status.InGame) && (activeApps.contains("League Of Legends") == false)){
            detector.updateStatus(Status.InLobby)
        }
            
        else if((detector.game == Game.LoL) && (detector.status != Status.InGame) && activeApps.contains("League Of Legends")){
            LoLDetector.updateStatus(Status.InGame)
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
        counter = 0
    }
    
    func update2() {
        counter = counter + 0.1
        self.timer.progress = CGFloat(counter / Float(GameDetector.countDownLength))
        var time:Int = Int(Float(GameDetector.countDownLength) - counter)
        self.countDown.stringValue = String(time)
        
        if(counter > Float(GameDetector.countDownLength)) {
            countDownTimer.invalidate()
            counter = 0
        }
    }
}
