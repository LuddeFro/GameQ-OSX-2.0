//
//  ContainerViewController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/21/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class ContainerViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainStoryboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)!
        let sourceViewController = mainStoryboard.instantiateControllerWithIdentifier("loginViewController") as! NSViewController
        self.insertChildViewController(sourceViewController, atIndex: 0)
        self.view.addSubview(sourceViewController.view)
        self.view.frame = sourceViewController.view.frame
    }
}
