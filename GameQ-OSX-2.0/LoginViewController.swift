//
//  ViewController.swift
//  Interface
//
//  Created by Fabian Wikström on 6/19/15.
//  Copyright (c) 2015 Fabian Wikström. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    
    @IBAction func loginButton(sender: AnyObject) {
    }
    
    @IBOutlet weak var loginButton: NSButton!
    
    @IBOutlet weak var signUpButton: NSButton!
    @IBOutlet weak var emailField: NSTextField!
    
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(12)
        let style = NSMutableParagraphStyle()
        style.alignment = .CenterTextAlignment
        
        loginButton.attributedTitle = NSAttributedString(string: "Login", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        signUpButton.attributedTitle = NSAttributedString(string: "Sign Up", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

