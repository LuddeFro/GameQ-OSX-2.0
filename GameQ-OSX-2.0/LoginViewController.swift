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
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

