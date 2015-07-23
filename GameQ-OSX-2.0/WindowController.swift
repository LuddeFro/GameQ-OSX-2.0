//
//  WindowController.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/19/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
        self.window!.titleVisibility = NSWindowTitleVisibility.Hidden
        self.window!.titlebarAppearsTransparent = true
        self.window!.styleMask |= NSFullSizeContentViewWindowMask
        self.window!.backgroundColor = Colors().backgroundColor
        self.window!.movableByWindowBackground = true
    }
    
}
