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
        
        if(passwordField1.stringValue != passwordField2.stringValue){
            dispatch_async(dispatch_get_main_queue()) {

            self.statusLabel.stringValue = "Passwords are not the same"
            self.passwordField1.stringValue = ""
            self.passwordField2.stringValue = ""
            }
        }
        
        else{
        
            dispatch_async(dispatch_get_main_queue()) {
              self.statusLabel.stringValue = "Creating Account..."
            }
            
            
        ConnectionHandler.register(emailField.stringValue, password: passwordField1.stringValue, finalCallBack:{ (success:Bool, err:String?) in
            
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("SignUpToMaster", sender: nil)
                }
            } else {
                println("nay")
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusLabel.stringValue = err!
                }
            }
        })
        }
    }
    
    @IBOutlet weak var passwordField2: NSSecureTextField!
    @IBOutlet weak var passwordField1: NSSecureTextField!
    @IBOutlet weak var emailField: NSTextField!
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
