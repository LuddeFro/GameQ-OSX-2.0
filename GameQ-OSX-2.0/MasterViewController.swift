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
    
    var counter = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getStatus:"), name:"updateStatus", object: nil)
        
        MasterController.start()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func getStatus(sender: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.gameStatus.stringValue = MasterController.game.rawValue
            self.statusLabel.stringValue = MasterController.status.rawValue
            self.timer.progress = CGFloat(MasterController.counter / MasterController.countDownLength)
        }
    }
}
