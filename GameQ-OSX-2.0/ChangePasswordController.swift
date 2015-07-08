//
//  ChangePasswordController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class ChangePasswordController: NSViewController {
        
        let font1 = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
        let style1 = NSMutableParagraphStyle()
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        submitButton.enabled = false
        style1.alignment = .CenterTextAlignment
        submitButton.attributedTitle = NSAttributedString(string: "Your password has changed", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
    }
    
    
    @IBOutlet weak var submitButton: OrangeButton!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
            style1.alignment = .CenterTextAlignment
            
            submitButton.attributedTitle = NSAttributedString(string: "Change Password", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
            
    }
}

