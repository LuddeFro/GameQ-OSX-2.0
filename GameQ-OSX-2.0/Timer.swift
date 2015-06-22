//
//  Timer.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/21/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class Timer: NSView {

    let circlePathLayer = CAShapeLayer()
    let circleRadius: CGFloat = 20.0
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        // Drawing code here.
        }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.wantsLayer = true
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.wantsLayer = true
        configure()
    }
    
    func configure() {
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 2
        circlePathLayer.fillColor = NSColor.whiteColor().CGColor
        circlePathLayer.strokeColor = NSColor.redColor().CGColor
        circlePathLayer.frame = bounds
        circlePathLayer.bounds = bounds
        layer!.addSublayer(circlePathLayer)
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        circleFrame.origin.x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        circleFrame.origin.y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        return circleFrame
    }
    
    func circlePath() -> NSBezierPath {
        return NSBezierPath(ovalInRect: circleFrame())
    }
}
