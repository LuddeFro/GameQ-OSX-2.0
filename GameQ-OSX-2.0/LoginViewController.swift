//
//  ViewController.swift
//  Interface
//
//  Created by Fabian Wikström on 6/19/15.
//  Copyright (c) 2015 Fabian Wikström. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
    
    @IBOutlet weak var loginProgress1: NSProgressIndicator!
    @IBOutlet weak var forgotPasswordButton: NSButton!
    
    @IBOutlet weak var loginProgress2: NSProgressIndicator!
    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.loginProgress1.startAnimation(self)
            self.loginProgress2.startAnimation(self)
            
        }
        
        
        ConnectionHandler.login(emailField.stringValue, password: passwordField.stringValue, finalCallBack:{ (success:Bool, err:String?) in
            if success {
                println("Jay")
                dispatch_async(dispatch_get_main_queue()) {
                    self.loginProgress1.stopAnimation(self)
                    self.loginProgress2.stopAnimation(self)
                    self.performSegueWithIdentifier("LoginToMaster", sender: nil)
                }
            } else {
                println("nay")
                dispatch_async(dispatch_get_main_queue()) {
                    self.loginProgress1.stopAnimation(self)
                    self.loginProgress2.stopAnimation(self)
                    self.statusLabel.stringValue = err!
                }
            }
        })
    }
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    @IBOutlet weak var loginButton: NSButton!
    
    @IBOutlet weak var signUpButton: NSButton!
    @IBOutlet weak var emailField: NSTextField!
    
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
        let style = NSMutableParagraphStyle()
        style.alignment = .CenterTextAlignment
        
        loginButton.attributedTitle = NSAttributedString(string: "Login", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        signUpButton.attributedTitle = NSAttributedString(string: "Sign Up", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        
        
        let font2 = NSFont(name: "Helvetica", size: 14) ?? NSFont.labelFontOfSize(14)
        let style2 = NSMutableParagraphStyle()
        style2.alignment = .CenterTextAlignment
        
        forgotPasswordButton.attributedTitle = NSAttributedString(string: "Forgot your password?", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style2, NSFontAttributeName: font2])
        
        
        ConnectionHandler.loginWithRememberedDetails({ (success:Bool, err:String?) in
            if success {
                println("Jay")
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("LoginToMaster", sender: nil)
                }
            }
        })
    }
}

