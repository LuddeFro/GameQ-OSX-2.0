//
//  DataHandler.swift
//  GameQ-Data-Gatherer
//
//  Created by Ludvig Fröberg on 19/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DataHandler:NSObject {
    
    static let sharedInstance = DataHandler()
    var folderName:String = ""
    
    func logPackets(log:String) {
        
        // kontrollera att mapparna finns
        var error:NSError?
        var masterFolderPath = (NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)![0] as! String).stringByAppendingPathComponent("GameQ-Caps")
        if (!NSFileManager.defaultManager().fileExistsAtPath(masterFolderPath)) {
            NSFileManager.defaultManager() .createDirectoryAtPath(masterFolderPath, withIntermediateDirectories: false, attributes: nil, error: &error)
        }
        var gameFolerPath = (NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)![0] as! String).stringByAppendingPathComponent("GameQ-Caps").stringByAppendingPathComponent(self.folderName)
        if (!NSFileManager.defaultManager().fileExistsAtPath(gameFolerPath)) {
            NSFileManager.defaultManager() .createDirectoryAtPath(gameFolerPath, withIntermediateDirectories: false, attributes: nil, error: &error)
        }
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateStyle = .MediumStyle
        var name = formatter.stringFromDate(date) + ".csv"
        name = name.filter({ $0 != Character(":") })
        
        
        //spara filen i pathen
        var path = (NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)![0] as! String).stringByAppendingPathComponent("GameQ-Caps").stringByAppendingPathComponent(folderName).stringByAppendingPathComponent(name)
        log.writeToFile(path, atomically: true, encoding:NSUTF8StringEncoding , error: nil)
        println("Saving to " + name)
    }
    
    func prompt() -> String {
        println()
        return String(NSString(data: NSFileHandle.fileHandleWithStandardInput().availableData, encoding:NSUTF8StringEncoding)!.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()))
    }
}