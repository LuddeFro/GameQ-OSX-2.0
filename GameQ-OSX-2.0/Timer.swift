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
        
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        var x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        var y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        
        var path:NSBezierPath = NSBezierPath()
        path.appendBezierPathWithArcWithCenter(NSPoint(x: x + circleRadius, y: y + circleRadius), radius: circleRadius, startAngle: 90, endAngle: -270, clockwise: true)
        
        path.lineWidth = 5
        NSColor(netHex: 0x323f4f).setStroke()
        path.stroke()
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
        progress = 0
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
    
    func circlePath() -> NSBezierPath {
        
        var circleFrame = CGRect(x: 0, y: 0, width: 2*circleRadius, height: 2*circleRadius)
        var x = CGRectGetMidX(circlePathLayer.bounds) - CGRectGetMidX(circleFrame)
        var y = CGRectGetMidY(circlePathLayer.bounds) - CGRectGetMidY(circleFrame)
        
        var path:NSBezierPath = NSBezierPath()
        path.appendBezierPathWithArcWithCenter(NSPoint(x: x + circleRadius, y: y + circleRadius), radius: circleRadius, startAngle: 90, endAngle: -270, clockwise: true)
    
        return path
    }
    
}
