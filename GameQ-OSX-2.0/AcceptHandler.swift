//
//  AcceptHandler.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 09/08/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation
import Cocoa

let dota=1, hon=2, csgo=3, hots=4, lol=5, dotareborn=6
var localGame:Int = 0
private let i:CGFloat = 22



class AcceptHandler:NSObject {
    static func acceptForGame(game:Game) {
         
        //generate coordinates x & y
        let option = CGWindowListOption(kCGWindowListOptionAll)
        let relativeToWindow = CGWindowID(0)
        let info = CGWindowListCopyWindowInfo(option, relativeToWindow).takeRetainedValue()
        let pid = getPIDFromGame(game)
        println(pid)
        var app:NSRunningApplication = NSRunningApplication(processIdentifier: pid)!
        
        app.activateWithOptions(NSApplicationActivationOptions.ActivateIgnoringOtherApps)
        usleep(1000000)
        
        var x:CGFloat = 0
        var y:CGFloat = 0
        var y2:CGFloat = 0
        
        for dict in info as! [ [ String : AnyObject] ] {
            println()
            println(dict.description)
            println()
            
            if let pidComp = dict["kCGWindowOwnerPID"] as? Int {
                let acmp = "\(pid)"
                let bcmp = "\(pidComp)"
                if acmp == bcmp {
                    if let boundsDic = dict["kCGWindowBounds"] as? [String:Int] {
                        //                        println(boundsDic["X"])
                        //                        println(boundsDic["Y"])
                        //                        println(boundsDic["Width"])
                        //                        println(boundsDic["Height"])
                        let xwindowcoord = boundsDic["X"]!
                        let ywindowcoord = boundsDic["Y"]!
                        let h = boundsDic["Height"]!
                        let w = boundsDic["Width"]!
                        
                        let xfractions:[Int:CGFloat] = [ /// distance x unbordered & bordered
                            1:CGFloat(xwindowcoord) + CGFloat(532)/(CGFloat(1286)/CGFloat(w)), //dota
                            //2:CGFloat(589)/(CGFloat(1280)/CGFloat(w)), //hon
                            //3:CGFloat(589)/(CGFloat(1280)/CGFloat(w)), //hots
                            4:CGFloat(xwindowcoord) + CGFloat(263)/(CGFloat(1280)/CGFloat(w)), //csgo
                            5:CGFloat(xwindowcoord) + CGFloat(589)/(CGFloat(1280)/CGFloat(w)), //lol
                            6:CGFloat(xwindowcoord) + CGFloat(550)/(CGFloat(1280)/CGFloat(w)), //dotareborn
                        ]
                        let yfractions:[Int:CGFloat] = [ /// distance y unbordered
                            1:CGFloat(ywindowcoord) + CGFloat(324)/(CGFloat(796)/CGFloat(h)), //dota
                            //2:CGFloat(589)/(CGFloat(1280)/CGFloat(h)), //hon
                            //3:CGFloat(589)/(CGFloat(1280)/CGFloat(h)), //hots
                            4:CGFloat(ywindowcoord) + CGFloat(192)/(CGFloat(800)/CGFloat(h)), //csgo
                            5:CGFloat(ywindowcoord) + CGFloat(445)/(CGFloat(800)/CGFloat(h)), //lol
                            6:CGFloat(ywindowcoord) + CGFloat(403)/(CGFloat(768)/CGFloat(h)), //dotareborn
                        ]
                        let diff:CGFloat = CGFloat(h) - i /// distance y bordered
                        let yfractionsBordered:[Int:CGFloat] = [
                            1:CGFloat(ywindowcoord) + CGFloat(324)/(CGFloat(796)/diff) + i, //dota
                            //2:CGFloat(589)/(CGFloat(1280)/diff), //hon
                            //3:CGFloat(589)/(CGFloat(1280)/CGFloat(h)), //hots
                            4:CGFloat(ywindowcoord) + CGFloat(192)/(CGFloat(800)/diff) + i, //csgo
                            5:CGFloat(ywindowcoord) + CGFloat(445)/(CGFloat(800)/diff) + i, //lol
                            6:CGFloat(ywindowcoord) + CGFloat(403)/(CGFloat(768)/diff) + i, //dotareborn
                        ]
                        
                        x = xfractions[localGame]!
                        y = yfractions[localGame]!
                        y2 = yfractionsBordered[localGame]!
                        
                        //generate mouse click events
                        let state:CGEventSourceStateID = CGEventSourceStateID(kCGEventSourceStateCombinedSessionState)
                        let eventSource:CGEventSource = CGEventSourceCreate(state).takeRetainedValue()
                        let eventMouseMove = CGEventCreateMouseEvent(nil, CGEventType(kCGEventMouseMoved), CGPointMake(x, y), CGMouseButton(kCGMouseButtonLeft)).takeRetainedValue()
                        let eventMouseDown = CGEventCreateMouseEvent(nil, CGEventType(kCGEventLeftMouseDown), CGPointMake(x, y), CGMouseButton(kCGMouseButtonLeft)).takeRetainedValue()
                        let eventMouseUp = CGEventCreateMouseEvent(nil, CGEventType(kCGEventLeftMouseUp), CGPointMake(x, y), CGMouseButton(kCGMouseButtonLeft)).takeRetainedValue()
                        
                        let eventMouseMove2 = CGEventCreateMouseEvent(nil, CGEventType(kCGEventMouseMoved), CGPointMake(x, y2), CGMouseButton(kCGMouseButtonLeft)).takeRetainedValue()
                        let eventMouseDown2 = CGEventCreateMouseEvent(nil, CGEventType(kCGEventLeftMouseDown), CGPointMake(x, y2), CGMouseButton(kCGMouseButtonLeft)).takeRetainedValue()
                        let eventMouseUp2 = CGEventCreateMouseEvent(nil, CGEventType(kCGEventLeftMouseUp), CGPointMake(x, y2), CGMouseButton(kCGMouseButtonLeft)).takeRetainedValue()
                        
                        //execute mouse click events
                        CGEventPost(CGEventTapLocation(kCGHIDEventTap), eventMouseMove)
                        usleep(10000)
                        //                        CGEventPost(CGEventTapLocation(kCGHIDEventTap), eventMouseDown)
                        usleep(10000)
                        //                        CGEventPost(CGEventTapLocation(kCGHIDEventTap), eventMouseUp)
                        usleep(10000)
                        //                        CGEventPost(CGEventTapLocation(kCGHIDEventTap), eventMouseMove2)
                        usleep(10000)
                        //                        CGEventPost(CGEventTapLocation(kCGHIDEventTap), eventMouseDown)
                        usleep(10000)
                        //                        CGEventPost(CGEventTapLocation(kCGHIDEventTap), eventMouseUp)
                        
                        //done
                        
                    }
                }
            }
        }
    }
    private static func getPIDFromGame(game:Game) -> pid_t {
        var ws = NSWorkspace.sharedWorkspace()
        var apps:[NSRunningApplication] = ws.runningApplications as! [NSRunningApplication]
        var activeApps:Set<String> = Set<String>()
        var appName:String = ""
        switch game {
        case .Dota2:
            appName = "dota_osx"
            
            for app in apps {
                var appProcName:String? = app.localizedName
                if appProcName == "dota_osx" {
                    localGame = dota
                    return app.processIdentifier
                } else if appProcName == "dota2" {
                    localGame = dotareborn
                    return app.processIdentifier
                }
            }
        case .CSGO:
            localGame = csgo
            appName = "csgo_osx"
        case .HoN:
            localGame = hon
            appName = "Heroes of Newerth"
        case .LoL:
            localGame = lol
            appName = "LolClient"
        case .HOTS:
            localGame = hots
            appName = "Heroes"
        default:
            return 0
        }
        
        for app in apps {
            var appProcName:String? = app.localizedName
            if(appProcName == appName) {
                return app.processIdentifier
            }
        }
        
        return 0
    }
}








