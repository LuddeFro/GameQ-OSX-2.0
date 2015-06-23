//
//  MyCustomSwiftAnimator.swift
//  NSViewControllerPresentations
//
//  Created by jonathan on 25/01/2015.
//  Copyright (c) 2015 net.ellipsis. All rights reserved.
//
//  based on:
//  http://stackoverflow.com/questions/26715636/animate-custom-presentation-of-viewcontroller-in-os-x-yosemite

import Cocoa

class MyCustomSwiftAnimator: NSObject, NSViewControllerPresentationAnimator {
    
    @objc func  animatePresentationOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        topVC.view.alphaValue = 0
        bottomVC.view.addSubview(topVC.view)
        var frame : CGRect = NSRectToCGRect(bottomVC.view.frame)
        frame = CGRectInset(frame, 0, 0)
        topVC.view.frame = NSRectFromCGRect(frame)
        let color: CGColorRef = NSColor(netHex: 0x465568).CGColor
        topVC.view.layer?.backgroundColor = color
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 1

        }, completionHandler: nil)
        
    }
    
    
    @objc func  animateDismissalOfViewController(viewController: NSViewController, fromViewController: NSViewController) {
        let bottomVC = fromViewController
        let topVC = viewController
        topVC.view.wantsLayer = true
        topVC.view.layerContentsRedrawPolicy = .OnSetNeedsDisplay
        
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 0.5
            topVC.view.animator().alphaValue = 0
            }, completionHandler: {
                topVC.view.removeFromSuperview()
        })
    }

}
