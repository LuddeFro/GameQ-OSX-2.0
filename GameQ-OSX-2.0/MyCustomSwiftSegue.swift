//
//  MyCustomSwiftSegue.swift
//  NSViewControllerPresentations
//
//  Created by jonathan on 25/01/2015.
//  Copyright (c) 2015 net.ellipsis. All rights reserved.
//

import Cocoa


class MyCustomSwiftSegue: NSStoryboardSegue {
    /*
      Objective-C NSStoryboardSegue can accept a nil string in the init method. 
      Swift NSStoryboardSegue will die with EXEC_BAD_ACCESS if it gets a nil string (if the Storyboad "identifier" field has not been filled in)
      One solution is to ensure you have an idenifier set in the storyboard (even it it is "")
      Another solution is to override the init method here and check for nil string before passing to super
    */
    override init(identifier: String?,
        source sourceController: AnyObject,
        destination destinationController: AnyObject) {
            var myIdentifier : String
            if identifier == nil {
                myIdentifier = ""
            } else {
                myIdentifier = identifier!
            }
            super.init(identifier: myIdentifier, source: sourceController, destination: destinationController)
    }
    
    override func perform() {
        
        // build from-to and parent-child view controller relationships
        let sourceViewController  = self.sourceController as! NSViewController
        let destinationViewController = self.destinationController as! NSViewController
        let containerViewController = sourceViewController.parentViewController! as NSViewController
        
        // add destinationViewController as child
        containerViewController.insertChildViewController(destinationViewController, atIndex: 1)
        
        // get the size of destinationViewController
        var targetSize = destinationViewController.view.frame.size
        var targetWidth = destinationViewController.view.frame.size.width
        var targetHeight = destinationViewController.view.frame.size.height
        
        // prepare for animation
        sourceViewController.view.wantsLayer = true
        destinationViewController.view.wantsLayer = true
        
        //perform transition
        containerViewController.transitionFromViewController(sourceViewController, toViewController: destinationViewController, options: NSViewControllerTransitionOptions.Crossfade, completionHandler: nil)
        
        //resize view controllers
        sourceViewController.view.animator().setFrameSize(targetSize)
        destinationViewController.view.animator().setFrameSize(targetSize)
        
        //resize and shift window
        var currentFrame = containerViewController.view.window?.frame
        var currentRect = NSRectToCGRect(currentFrame!)
        var horizontalChange = (targetWidth - containerViewController.view.frame.size.width)/2
        var verticalChange = (targetHeight - containerViewController.view.frame.size.height)/2
        var newWindowRect = NSMakeRect(currentRect.origin.x - horizontalChange, currentRect.origin.y - verticalChange, targetWidth, targetHeight)
        containerViewController.view.window?.setFrame(newWindowRect, display: true, animate: true)
        
        // lose the sourceViewController, it's no longer visible
        containerViewController.removeChildViewControllerAtIndex(0)
        
    }
}


