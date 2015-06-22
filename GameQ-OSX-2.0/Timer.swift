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
    let circleRadius: CGFloat = 75
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
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
        circlePathLayer.strokeStart = 0.0
        progress = 0.9
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 5
        circlePathLayer.fillColor = NSColor.clearColor().CGColor
        circlePathLayer.strokeColor = NSColor(netHex: 0xFF6861).CGColor
        layer!.addSublayer(circlePathLayer)
        }
    
    override func resizeSubviewsWithOldSize(oldSize: NSSize) {
        super.resizeSubviewsWithOldSize(oldSize)
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().CGPath
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
