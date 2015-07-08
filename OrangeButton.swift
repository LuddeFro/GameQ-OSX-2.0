//
//  LoginButton.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class OrangeButton: NSButton {
    
    override func drawRect(dirtyRect: NSRect) {
        var path = NSBezierPath(roundedRect: dirtyRect, xRadius: 3, yRadius: 3)
        Colors().Orange.setFill()
        path.fill()
        super.drawRect(dirtyRect)
    }
}
