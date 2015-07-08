//
//  ReportController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class ReportController: NSViewController {

    @IBOutlet weak var submitButton: NSButton!
    @IBAction func submitButtonPressed(sender: AnyObject) {
    }
    
    @IBOutlet weak var feedbackLabel: NSButtonCell!
    @IBOutlet weak var missedQueueLabel: NSButtonCell!
    @IBOutlet weak var unwantedLabel: NSButtonCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
        
        let font1 = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
        let style1 = NSMutableParagraphStyle()
        style1.alignment = .CenterTextAlignment
        
        submitButton.attributedTitle = NSAttributedString(string: "Feedback", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
        
        let font2 = NSFont(name: "Helvetica", size: 12) ?? NSFont.labelFontOfSize(12)
        let style2 = NSMutableParagraphStyle()
        style2.alignment = .LeftTextAlignment

        feedbackLabel.attributedTitle = NSAttributedString(string: "Feedback", attributes: [ NSForegroundColorAttributeName : NSColor.blackColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
        
        missedQueueLabel.attributedTitle = NSAttributedString(string: "Missed Queue", attributes: [ NSForegroundColorAttributeName : NSColor.blackColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
        
        unwantedLabel.attributedTitle = NSAttributedString(string: "Unwanted Notification", attributes: [ NSForegroundColorAttributeName : NSColor.blackColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
    }
}
