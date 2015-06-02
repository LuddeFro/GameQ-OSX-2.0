//
//  DataHandler.swift
//  GameQ-Data-Gatherer
//
//  Created by Ludvig Fröberg on 19/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class DataHandler:NSObject {
    
    struct Static {
        static var game:String = "Dota"
    }
    
    class func logPackets(array:[Packet]) {
        var log:String = ""
        for i in 0..<array.count {
            log = "\(log)\(array[i].srcPort),\(array[i].dstPort),\(array[i].captureTime),\(array[i].packetLength)\n"
            array[i]
        }
        
        // kontrollera att mapparna finns
        var error:NSError?
        var masterFolderPath = (NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)![0] as! String).stringByAppendingPathComponent("GameQ-Caps")
        if (!NSFileManager.defaultManager().fileExistsAtPath(masterFolderPath)) {
            NSFileManager.defaultManager() .createDirectoryAtPath(masterFolderPath, withIntermediateDirectories: false, attributes: nil, error: &error)
        }
        var gameFolerPath = (NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)![0] as! String).stringByAppendingPathComponent("GameQ-Caps").stringByAppendingPathComponent(Static.game)
        if (!NSFileManager.defaultManager().fileExistsAtPath(gameFolerPath)) {
            NSFileManager.defaultManager() .createDirectoryAtPath(gameFolerPath, withIntermediateDirectories: false, attributes: nil, error: &error)
        }
        
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        formatter.dateStyle = .MediumStyle
        let name = formatter.stringFromDate(date) + ".csv"
        
        //spara filen i pathen
        var path = (NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)![0] as! String).stringByAppendingPathComponent("GameQ-Caps").stringByAppendingPathComponent(Static.game).stringByAppendingPathComponent(name)
        log.writeToFile(path, atomically: true, encoding:NSUTF8StringEncoding , error: nil)
    }
    
    class func prompt() -> String {
        println()
        return String(NSString(data: NSFileHandle.fileHandleWithStandardInput().availableData, encoding:NSUTF8StringEncoding)!.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet()))
    }
}