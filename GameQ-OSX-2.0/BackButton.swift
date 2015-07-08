//
//  BackButton.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 7/8/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class BackButton: NSButton {
    
    override func drawRect(dirtyRect: NSRect) {
        var path = NSBezierPath(roundedRect: dirtyRect, xRadius: 3, yRadius: 3)
        Colors().LightBlue.setFill()
        path.fill()
        
        let font = NSFont(name: "Helvetica", size: 16) ?? NSFont.labelFontOfSize(12)
        let style = NSMutableParagraphStyle()
        style.alignment = .CenterTextAlignment
        
        self.attributedTitle = NSAttributedString(string: "Back", attributes: [ NSForegroundColorAttributeName : NSColor.whiteColor(), NSParagraphStyleAttributeName : style, NSFontAttributeName: font])
        super.drawRect(dirtyRect)
    }
}
