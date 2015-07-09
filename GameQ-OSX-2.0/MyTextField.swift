//
//  MyTextField.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/7/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class MyTextField: NSTextField {

    override func drawRect(dirtyRect: NSRect) {
        var path = NSBezierPath(roundedRect: dirtyRect, xRadius: 5, yRadius: 5)
        NSColor.greenColor().setFill()
        path.fill()
    }
}
