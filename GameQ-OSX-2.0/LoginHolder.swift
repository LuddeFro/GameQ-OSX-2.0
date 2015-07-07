//
//  LoginHolder.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/7/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class LoginHolder: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        var path = NSBezierPath(roundedRect: dirtyRect, xRadius: 10, yRadius: 10)
        NSColor.whiteColor().setFill()
        NSColor(netHex: 0x323f4f).setStroke()
        path.lineWidth = 2
        path.fill()
        path.stroke()
        self.wantsLayer = true
        self.layer!.cornerRadius  = 10
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        self.wantsLayer = true
        self.layer!.cornerRadius  = 10
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        self.layer!.cornerRadius  = 10
    }
}

