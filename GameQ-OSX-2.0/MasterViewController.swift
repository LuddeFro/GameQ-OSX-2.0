//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
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
        NSApplication.sharedApplication().terminate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func update() {
        
        var ws = NSWorkspace.sharedWorkspace()
        var apps:[NSRunningApplication] = ws.runningApplications as! [NSRunningApplication]
        var activeApps:Set<String> = Set<String>()
        
        for app in apps {
            var appName:String? = app.localizedName
            if(appName != nil){activeApps.insert(appName!)}
        }
        
        if(activeApps.contains("dota_osx") && MasterController.game == Game.NoGame){
            MasterController.gameDetection(Game.Dota)
        }
            
        else if(activeApps.contains("csgo_osx") && MasterController.game == Game.NoGame){
            MasterController.gameDetection(Game.CSGO)
        }
        
        gameStatus.stringValue = MasterController.game.rawValue
        statusLabel.stringValue = MasterController.status.rawValue
    }
}
