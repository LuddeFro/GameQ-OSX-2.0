//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    
    @IBAction func startButtonPressed(sender: NSButton) {
        println("Starting Detection")
        DotaDetector.startDetection()
    }
    
    @IBAction func capButtonPressed(sender: NSButton) {
       println("Saving File")
       DotaDetector.saveCapture()
    }
    
    @IBAction func stopButtonPressed(sender: NSButton) {
       DotaDetector.stopDetection()
    }
    
    
    @IBAction func quitButtonPressed(sender: NSButton) {
        DotaDetector.stopDetection()
        NSApplication.sharedApplication().terminate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
