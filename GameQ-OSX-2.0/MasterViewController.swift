//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    
   
    @IBAction func startDotaButtonPressed(sender: NSButton) {DotaDetector.startDetection()}
    @IBAction func startHoNButtonPressed(sender: NSButton) {HoNDetector.startDetection()}
    
    @IBAction func capButtonPressed(sender: NSButton) {
        if(DotaDetector.running){
       DotaDetector.saveCapture()
       }
       else if(HoNDetector.running){
        HoNDetector.saveCapture()
        }
    }
    
    @IBAction func stopButtonPressed(sender: NSButton) {
       
        if(DotaDetector.running){
            DotaDetector.stopDetection()
        }
        else if(HoNDetector.running){
            HoNDetector.stopDetection()
        }
    }
    
    @IBAction func quitButtonPressed(sender: NSButton) {
        DotaDetector.stopDetection()
        HoNDetector.stopDetection()
        NSApplication.sharedApplication().terminate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
     func update() {
        
            var ws = NSWorkspace.sharedWorkspace()
            var apps = ws.runningApplications
            var activeApps:Set<String> = Set<String>()
            
            for app in apps as! [NSRunningApplication] {
                activeApps.insert(app.localizedName!)
            }
            
            if(activeApps.contains("dota_osx") && !DotaDetector.running){
                DotaDetector.startDetection()
            }
        }
    }
