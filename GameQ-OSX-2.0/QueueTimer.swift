//
//  QueueTimer.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/23/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa

class QueueTimer: NSView {
    
    var isRotating = false
    let rotationTime:CFTimeInterval = 4
    var timer: NSTimer!
    var isGame:Bool = false
    
    override func drawRect(dirtyRect: NSRect) {
        
        var center =  CGPointMake((self.bounds.origin.x + (self.bounds.size.width / 2)),
            (self.bounds.origin.y + (self.bounds.size.height / 2)))
        
        var path = NSBezierPath()
        path.appendBezierPathWithArcWithCenter(center, radius: 67, startAngle: 0, endAngle: 360)
        path.lineWidth = 3
        if(isGame){NSColor(netHex: 0x8fd8f7).setStroke()}
        else{NSColor(netHex: 0x323f4f).setStroke()}

        path.stroke()
        
        if(isRotating){
        var path2 = NSBezierPath()
        path2.appendBezierPathWithArcWithCenter(center, radius: 67, startAngle: 0, endAngle: 60)
        path2.lineWidth = 3
        NSColor(netHex: 0x8fd8f7).setStroke()
        path2.stroke()
        }
      }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.isRotating == true {
            self.rotate360Degrees(completionDelegate: self)
        } else {
        }
    }
    
    func start(){
        if(isRotating == false){
        self.isRotating = true
        self.needsDisplay = true
        self.rotate360Degrees(duration: 4, completionDelegate: self)
        }
    }
    
    func reset() {
        self.isRotating = false
        self.needsDisplay = true
        println("asd")
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 0.5, completionDelegate: AnyObject? = nil) {
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI * 2.0)
        rotateAnimation.duration = rotationTime
        rotateAnimation.delegate = self
     
        self.wantsLayer = true
        self.layer!.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) )
        self.layer!.anchorPoint = CGPointMake(0.5, 0.5)
        self.layer!.addAnimation(rotateAnimation, forKey: nil)
    }
}
