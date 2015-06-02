//
//  MasterViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/2/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MasterViewController: NSViewController {
    
    
   
    @IBAction func startDotaButtonPressed(sender: NSButton) {
        println("Starting Dota Detection")
        DotaDetector.startDetection()
        
    }
    
    
    @IBAction func startHoNButtonPressed(sender: NSButton) {
        println("Starting HoN Detection")
        HoNDetector.startDetection()
    }
    
    @IBAction func capButtonPressed(sender: NSButton) {
       println("Saving File")
       if(DotaDetector.running){
       DotaDetector.saveCapture()
       }
       else if(HoNDetector.running){
        HoNDetector.saveCapture()
        }
    }
    
    @IBAction func stopButtonPressed(sender: NSButton) {
        println("Stopped Detection")
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
    }
}
