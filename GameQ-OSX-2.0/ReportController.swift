//
//  ReportController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class ReportController: NSViewController {
    
    @IBOutlet weak var commentField: NSTextField!
    @IBOutlet weak var submitButton: NSButtonCell!
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            self.submitButton.enabled = false
            self.submitButton.attributedTitle = NSAttributedString(string: "Submitting Feedback", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : self.style1, NSFontAttributeName: self.font1])
        }
        if(feedbackLabel.state == NSOnState && !commentField.stringValue.isEmpty){
            ConnectionHandler.submitFeedback(commentField.stringValue, finalCallBack: {(success: Bool, error:String?) in
                if(success){
                    dispatch_async(dispatch_get_main_queue()) {
                        self.submitButton.attributedTitle = NSAttributedString(string: "Thank You!", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : self.style1, NSFontAttributeName: self.font1])
                    }}
            })}
            
        else if(missedQueueLabel.state == NSOnState && GameDetector.game != Game.NoGame){
            ConnectionHandler.submitCSV(GameDetector.detector.fileToString(), game: Encoding.getIntFromGame(GameDetector.detector.game), type: 1, finalCallBack: {(success:Bool, error:String?) in
                if(success){
                    dispatch_async(dispatch_get_main_queue()) {
                        self.submitButton.attributedTitle = NSAttributedString(string: "Thank You!", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : self.style1, NSFontAttributeName: self.font1])
                    }}
            })
        }
            
        else if(unwantedLabel.state == NSOnState && GameDetector.game != Game.NoGame){
            ConnectionHandler.submitCSV(GameDetector.detector.fileToString(), game: Encoding.getIntFromGame(GameDetector.detector.game), type: 2, finalCallBack: {(success:Bool, error:String?) in
                if(success){
                    dispatch_async(dispatch_get_main_queue()) {
                        self.submitButton.attributedTitle = NSAttributedString(string: "Thank You!", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : self.style1, NSFontAttributeName: self.font1])
                    }}
            })
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            let font1 = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
            let style1 = NSMutableParagraphStyle()
            style1.alignment = .CenterTextAlignment
            
            self.submitButton.attributedTitle = NSAttributedString(string: "Thank you!", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
            self.submitButton.enabled = false
        }
    }
    
    @IBOutlet weak var feedbackLabel: NSButtonCell!
    @IBOutlet weak var missedQueueLabel: NSButtonCell!
    @IBOutlet weak var unwantedLabel: NSButtonCell!
    
    let font1 = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
    let style1 = NSMutableParagraphStyle()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        
        style1.alignment = .CenterTextAlignment
        
        submitButton.attributedTitle = NSAttributedString(string: "Submit", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
        
        let font2 = NSFont(name: "Helvetica", size: 14) ?? NSFont.labelFontOfSize(14)
        let style2 = NSMutableParagraphStyle()
        style2.alignment = .LeftTextAlignment
        
        feedbackLabel.attributedTitle = NSAttributedString(string: "General Feedback", attributes: [ NSForegroundColorAttributeName : NSColor.blackColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
        
        missedQueueLabel.attributedTitle = NSAttributedString(string: "I did not get a notification", attributes: [ NSForegroundColorAttributeName : NSColor.blackColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
        
        unwantedLabel.attributedTitle = NSAttributedString(string: "I got a notification when I shouldn't", attributes: [ NSForegroundColorAttributeName : NSColor.blackColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
    }
}
