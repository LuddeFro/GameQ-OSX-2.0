//
//  Helpers.swift
//  GameQ-OSX-2.0
//
//  Created by Fabian Wikström on 6/18/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

extension NSColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

class CustomLine: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        Colors().LightBlue.setFill()
        NSRectFill(dirtyRect);
    }
}

class CustomLine2: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        Colors().LineGray.setFill()
        NSRectFill(dirtyRect);
    }
}

extension String {
    func filter(pred: Character -> Bool) -> String {
        var res = String()
        for c in self {
            if (pred(c)) {
                res.append(c)
            }
        }
        return res
    }
}

extension NSBezierPath {
    
    var CGPath: CGPathRef {
        
        get {
            return self.transformToCGPath()
        }
    }
    
    
    /// Transforms the NSBezierPath into a CGPathRef
    ///
    /// :returns: The transformed NSBezierPath
    private func transformToCGPath() -> CGPathRef {
        
        // Create path
        var path = CGPathCreateMutable()
        var points = UnsafeMutablePointer<NSPoint>.alloc(3)
        let numElements = self.elementCount
        
        if numElements > 0 {
            
            var didClosePath = true
            
            for index in 0..<numElements {
                
                let pathType = self.elementAtIndex(index, associatedPoints: points)
                
                switch pathType {
                    
                case .MoveToBezierPathElement:
                    CGPathMoveToPoint(path, nil, points[0].x, points[0].y)
                case .LineToBezierPathElement:
                    CGPathAddLineToPoint(path, nil, points[0].x, points[0].y)
                    didClosePath = false
                case .CurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, nil, points[0].x, points[0].y, points[1].x, points[1].y, points[2].x, points[2].y)
                    didClosePath = false
                case .ClosePathBezierPathElement:
                    CGPathCloseSubpath(path)
                    didClosePath = true
                }
            }
            
            if !didClosePath { CGPathCloseSubpath(path) }
        }
        
        points.dealloc(3)
        return path
    }
}



