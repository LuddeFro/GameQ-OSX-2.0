//
//  AppDelegate.swift
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Cocoa
import AudioToolbox
import CoreAudio
import AppKit


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem : NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var preferencesItem : NSMenuItem = NSMenuItem()
    var loginItem : NSMenuItem = NSMenuItem()
    var quitItem : NSMenuItem = NSMenuItem()
    var gameItem: NSMenuItem = NSMenuItem()
    var statusItem:NSMenuItem = NSMenuItem()
    var emailItem : NSMenuItem = NSMenuItem()
    var logOutItem : NSMenuItem = NSMenuItem()
    var windowController:NSWindowController?
    var programTimer:NSTimer = NSTimer()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        ConnectionHandler.loginWithRememberedDetails({ (success:Bool, err:String?) in
            dispatch_async(dispatch_get_main_queue()) {
                let mainStoryboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)!
                self.windowController = mainStoryboard.instantiateControllerWithIdentifier("WindowController") as? NSWindowController
            }
            if success {
                self.didLogin()
            }
            else{
                dispatch_async(dispatch_get_main_queue()) {
                    self.menu.removeAllItems()
                    self.menu.addItem(self.loginItem)
                    self.menu.addItem(self.quitItem)
                    self.windowController?.showWindow(self)
                    self.windowController?.window?.orderFrontRegardless()
                }
            }})
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getStatus:"), name:"updateStatus", object: nil)
    }
    
    
    func applicationWillTerminate(aNotification: NSNotification) {
        ConnectionHandler.setStatus(Encoding.getIntFromGame(Game.NoGame), status: Encoding.getIntFromStatus(Status.Offline), finalCallBack:{ (success:Bool, err:String?) in
            })

        programTimer.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Add statusBarItem
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.image = NSImage(named: "statusIcon")
        
        loginItem.title = "Login"
        loginItem.action = Selector("setWindowVisible:")
        loginItem.keyEquivalent = ""
        
        preferencesItem.title = "Show App"
        preferencesItem.action = Selector("setWindowVisible:")
        preferencesItem.keyEquivalent = ""
        
        logOutItem.title = "Log Out"
        logOutItem.action = Selector("logOutPressed:")
        logOutItem.keyEquivalent = ""
        
        quitItem.title = "Quit"
        quitItem.action = Selector("quitApplication:")
        quitItem.keyEquivalent = ""
    }
    
    func getStatus(sender: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.gameItem.title = Encoding.getStringFromGame(GameDetector.game)
            self.statusItem.title = Encoding.getStringFromGameStatus(GameDetector.game, status: GameDetector.status)
        }
    }
    
    func setWindowVisible(sender: AnyObject){
        dispatch_async(dispatch_get_main_queue()) {
            
            self.windowController?.showWindow(sender)
            self.windowController?.window?.orderFrontRegardless()
        }
    }
    
    func logOutPressed(sender: AnyObject){
        NSNotificationCenter.defaultCenter().postNotificationName("logOut", object: nil)
        self.didLogOut()
    }
    
    func quitApplication(sender: AnyObject){
        programTimer.invalidate()
        NSApplication.sharedApplication().terminate(self)
    }
    
    func didLogin(){
        dispatch_async(dispatch_get_main_queue()) {
            GameDetector.updateStatus(Status.Online)
            self.programTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
            self.gameItem.title = Encoding.getStringFromGame(GameDetector.game)
            self.gameItem.enabled = false
            self.statusItem.title = Encoding.getStringFromGameStatus(GameDetector.game, status: GameDetector.status)
            self.statusItem.enabled = false
            self.emailItem.title = ConnectionHandler.loadEmail()!
            self.emailItem.enabled = false
            self.menu.removeAllItems()
            self.menu.addItem(self.emailItem)
            self.menu.addItem(self.gameItem)
            self.menu.addItem(self.statusItem)
            self.menu.addItem(NSMenuItem.separatorItem())
            self.menu.addItem(self.preferencesItem)
            self.menu.addItem(self.logOutItem)
            self.menu.addItem(self.quitItem)
        }
    }
    
    func didLogOut(){
         dispatch_async(dispatch_get_main_queue()) {
        self.menu.removeAllItems()
        self.menu.addItem(self.loginItem)
        self.menu.addItem(self.quitItem)
        GameDetector.detector.stopDetection()
        self.programTimer.invalidate()}
        ConnectionHandler.logout({ (success:Bool, err:String?) in})
    }
    
    func update() {
        var ws = NSWorkspace.sharedWorkspace()
        var apps:[NSRunningApplication] = ws.runningApplications as! [NSRunningApplication]
        var activeApps:Set<String> = Set<String>()
        var newGame:Game = Game.NoGame
        
        for app in apps {
            var appName:String? = app.localizedName
            if(appName != nil){activeApps.insert(appName!)}
        }
        
        if(activeApps.contains("dota_osx") || activeApps.contains("dota2")){
            GameDetector.detector = DotaDetector.self
            newGame = Game.Dota2
        }
            
        else if(activeApps.contains("csgo_osx")){
            GameDetector.detector = CSGODetector.self
            newGame = Game.CSGO
        }
            
        else if(activeApps.contains("Heroes")){
            GameDetector.detector = HOTSDetector.self
            newGame = Game.HOTS
        }
            
        else if(activeApps.contains("Heroes of Newerth")){
            GameDetector.detector = HoNDetector.self
            newGame = Game.HoN
        }
            
        else if(activeApps.contains("LolClient")){
            GameDetector.detector = LoLDetector.self
            newGame = Game.LoL
        }
            
        else {newGame = Game.NoGame}
        
        if(GameDetector.game != newGame && newGame != Game.NoGame){
            GameDetector.detector.startDetection()
            GameDetector.game = newGame
        }
            
        else if(GameDetector.game != newGame && newGame == Game.NoGame) {
            GameDetector.detector.stopDetection()
            GameDetector.game = newGame
        }
        
        
        //Lol Specific shit
        if(( GameDetector.detector.game == Game.LoL) && (GameDetector.detector.status == Status.InGame) && (activeApps.contains("League Of Legends") == false)){
            GameDetector.detector.updateStatus(Status.InLobby)
        }
            
        else if(( GameDetector.detector.game == Game.LoL) && ( GameDetector.detector.status != Status.InGame) && activeApps.contains("League Of Legends")){
            LoLDetector.updateStatus(Status.InGame)
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "io.gameq.com.GameQ_OSX_2_0" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as! NSURL
        return appSupportURL.URLByAppendingPathComponent("io.gameq.com.GameQ_OSX_2_0")
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("GameQ_OSX_2_0", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var shouldFail = false
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("GameQ_OSX_2_0.storedata")
            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                coordinator = nil
            }
        }
        
        if shouldFail || (error != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error!)
            return nil
        } else {
            return coordinator
        }
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
            }
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSApplication.sharedApplication().presentError(error!)
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        if let moc = self.managedObjectContext {
            return moc.undoManager
        } else {
            return nil
        }
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if let moc = managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
                return .TerminateCancel
            }
            
            if !moc.hasChanges {
                return .TerminateNow
            }
            
            var error: NSError? = nil
            if !moc.save(&error) {
                // Customize this code block to include application-specific recovery steps.
                let result = sender.presentError(error!)
                if (result) {
                    return .TerminateCancel
                }
                
                let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
                let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
                let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
                let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
                let alert = NSAlert()
                alert.messageText = question
                alert.informativeText = info
                alert.addButtonWithTitle(quitButton)
                alert.addButtonWithTitle(cancelButton)
                
                let answer = alert.runModal()
                if answer == NSAlertFirstButtonReturn {
                    return .TerminateCancel
                }
            }
        }
        // If we got here, it is time to quit.
        return .TerminateNow
    }
}