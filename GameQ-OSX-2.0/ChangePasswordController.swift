//
//  ChangePasswordController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class ChangePasswordController: NSViewController {
    
    @IBOutlet weak var repeatPassword: NSSecureTextField!
    @IBOutlet weak var newPassword: NSSecureTextField!
    @IBOutlet weak var currentPassword: NSSecureTextField!
    @IBOutlet weak var statusLabel: NSTextField!
    let font1 = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(16)
    let style1 = NSMutableParagraphStyle()
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
        if(newPassword.stringValue != repeatPassword.stringValue){
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.stringValue = "Passwords are not the same"
            }
        }
            
        else{
            dispatch_async(dispatch_get_main_queue()) {
                self.statusLabel.stringValue = ""
                self.submitButton.enabled = false
            }
            
            ConnectionHandler.updatePassword(ConnectionHandler.loadEmail()!, password: currentPassword.stringValue, newPassword: newPassword.stringValue, finalCallBack: {(success:Bool, error:String?) in
                
                if(success){
                    dispatch_async(dispatch_get_main_queue()) {
                        self.style1.alignment = .CenterTextAlignment
                        self.submitButton.attributedTitle = NSAttributedString(string: "Your password has been changed", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : self.style1, NSFontAttributeName: self.font1])
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
                })}}
    
    
    @IBOutlet weak var submitButton: OrangeButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.appearance = NSAppearance(named: NSAppearanceNameAqua)
        style1.alignment = .CenterTextAlignment
        
        submitButton.attributedTitle = NSAttributedString(string: "Change Password", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style1, NSFontAttributeName: font1])
        
    }
}

