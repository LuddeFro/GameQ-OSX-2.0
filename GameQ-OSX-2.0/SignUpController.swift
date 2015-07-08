//
//  SignUppController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/7/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class SignUpController: NSViewController {
    
    @IBAction func signUpPressed(sender: AnyObject) {
    performSegueWithIdentifier("SignUpToMaster", sender: nil)
    }
    
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var backButtonPressed: NSButton!
    
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var signUpButton: NSButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let font = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(12)
        let style = NSMutableParagraphStyle()
        style.alignment = .CenterTextAlignment
        
        signUpButton.attributedTitle = NSAttributedString(string: "Sign Up", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        backButton.attributedTitle = NSAttributedString(string: "Back", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
    }
    
}
