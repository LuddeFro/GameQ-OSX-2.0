//
//  QueueTimer.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/23/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class QueueTimer: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        
        var center =  CGPointMake((self.bounds.origin.x + (self.bounds.size.width / 2)),
            (self.bounds.origin.y + (self.bounds.size.height / 2)))
        
        var path = NSBezierPath()
        path.appendBezierPathWithArcWithCenter(center, radius: 67, startAngle: 0, endAngle: 270)
        path.lineWidth = 3
        NSColor(netHex: 0x323f4f).setStroke()
        path.stroke()
    }
}
