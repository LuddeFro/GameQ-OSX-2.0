//
//  ForgotPasswordController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class ForgotPasswordController: NSViewController {
    
    
    
    @IBOutlet weak var emailField: NSTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    let font1 = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
    let style1 = NSMutableParagraphStyle()
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
       
         dispatch_async(dispatch_get_main_queue()) {
            self.submitButton.enabled = false
          }
        
        ConnectionHandler.forgotPassword(emailField.stringValue, finalCallBack:{(success:Bool, error:String?) in
            if success{
                dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.stringValue = "Success!"
                self.style1.alignment = .CenterTextAlignment
                self.submitButton.attributedTitle = NSAttributedString(string: "A new password has been sent", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : self.style1, NSFontAttributeName: self.font1])
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue()) {
                if(error! != "404"){
                    self.statusLabel.stringValue = error!}
                else {
                    self.statusLabel.stringValue = "No Internet Connection"}
            self.submitButton.enabled = true
                }
            }
            })
    }

    @IBOutlet weak var submitButton: NSButton!
        override func viewDidLoad() {
            super.viewDidLoad()
            self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
            style1.alignment = .CenterTextAlignment
            
            submitButton.attributedTitle = NSAttributedString(string: "Send me a new password", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
            
        }
    }
