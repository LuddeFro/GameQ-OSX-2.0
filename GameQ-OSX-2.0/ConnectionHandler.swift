//
//  File.swift
//  ConnectionTester
//
//  Created by Ludvig Fröberg on 08/06/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation
import AppKit
import CoreData

class ConnectionHandler : NSObject {
    
    static let baseURL:String = "http://server.gameq.io:8080/ios/"
    static let deviceIdKey:String = "device_id_key"
    static let tokenKey:String = "token_key" //only mobile
    private static var sessionId:String = ""
    
    
    private static func getStringFrom(json:Dictionary<String, AnyObject>, key:String) -> String {
        if let value = (json[key] as? String) {
            return value
        } else { return "" }
    }
    
    private static func getIntFrom(json:Dictionary<String, AnyObject>, key:String) -> Int {
        if let value = (json[key] as? String) {
            if value != "" && count(value) > 0 && value != "null" {
                println("value: \(value)")
                return value.toInt()!
            } else { return 0 }
        } else { return 0 }
    }
    
    private static func postRequest(arguments:String, apiExtension:String, responseHandler:(responseJSON:AnyObject!) -> ()) {
        let urlString = "\(baseURL)\(apiExtension)?key=68440fe0484ad2bb1656b56d234ca5f463f723c3d3d58c3398190877d1d963bb&\(arguments)"
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        
        request.HTTPBody = "".dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                println("error=\(error)")
                return
            }
            
            println("response = \(response)")
            let responseString = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("responseString = \(responseString)")
            
            var jsonErrorOptional:NSError?
            let responseJSON:AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &jsonErrorOptional)
            responseHandler(responseJSON: responseJSON)
        }
        task.resume()
    }
    
    static func login(email:String, password:String, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "login"
        var diString = ""
        if let deviceId = loadDeviceId() {
            diString = "device_id=\(deviceId)"
        }
        var tokenString = ""
        if let token = loadToken() { //only mobile
            tokenString = "token=\(token)"
        }
        //let arguments = "email=\(email)&password=\(password)&\(tokenString)&\(diString)" // mobile version
        let arguments = "email=\(email)&password=\(password)&\(diString)" // osx version
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
        
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    let retDI = self.getStringFrom(json, key: "device_id")
                    if retDI != ""{
                        self.saveDeviceId(retDI)
                    }
                    self.sessionId = self.getStringFrom(json, key: "session_token")
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func logout(finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "logout"
        var diString = ""
        let deviceId = loadDeviceId()
        let arguments = "session_token=\(sessionId)&device_id=\(deviceId)"
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //logout success
                    self.sessionId = ""
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func register(email:String, password:String, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "register"
        var diString = ""
        if let deviceId = loadDeviceId() {
            diString = "device_id=\(deviceId)"
        }
        var tokenString = ""
        if let token = loadToken() { //only mobile
            tokenString = "token=\(token)"
        }
        //let arguments = "email=\(email)&password=\(password)&\(tokenString)&\(diString)" // mobile version
        let arguments = "email=\(email)&password=\(password)&\(diString)" // osx version
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    let retDI = self.getStringFrom(json, key: "device_id")
                    if retDI != ""{
                        self.saveDeviceId(retDI)
                    }
                    self.sessionId = self.getStringFrom(json, key: "session_token")
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func setStatus(game:Int?, status:Int, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "setStatus"
        let deviceId = loadDeviceId()
        var gameString:String = ""
        if let gameId = game {
            gameString = "game=\(gameId)"
        }
        let arguments = "session_token=\(sessionId)&status=\(status)&device_id=\(deviceId)&\(gameString)"
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //set status success
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func getStatus(finalCallBack:(success:Bool, err:String?, status:Int?, game:Int?)->()) {
        let apiExtension = "getStatus"
        let deviceId = loadDeviceId()
        let arguments = "session_token=\(sessionId)&device_id=\(deviceId)"
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            var game:Int? = nil
            var status:Int? = nil
            
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //success
                    game = self.getIntFrom(json, key: "game")
                    status = self.getIntFrom(json, key: "status")
                    if game == 0 {
                        game = nil
                    }
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err, status:status, game:game)
        })
    }
    
    static func updateToken(token:String, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "updateToken"
        let deviceId = loadDeviceId()
        let arguments = "session_token=\(sessionId)&device_id=\(deviceId)&token=\(token)"
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //success
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func push(game:Int, acceptBefore:NSDate, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "push"
        let deviceId = loadDeviceId()
        let arguments = "session_token=\(sessionId)&device_id=\(deviceId)&game=\(game)&accept_before=\(Int(acceptBefore.timeIntervalSince1970))"
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //success
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func versionControl(finalCallBack:(success:Bool, err:String?, newestVersion:String?, link:String?)->()) {
        let apiExtension = "versionControl"
        let arguments = ""
        //let arguments = "os=mac" //os = mac or os = pc , only used by computers
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            var newestVersion:String? = nil
            var downloadLink:String? = nil
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //success
                    newestVersion = self.getStringFrom(json, key: "current_version")
                    downloadLink = self.getStringFrom(json, key: "download_link")
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err, newestVersion:newestVersion, link:downloadLink)
        })
    }
    
    static func submitCSV(csvString:String, game:Int, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "submitCSV"
        let deviceId = loadDeviceId()
        let arguments = "session_token=\(sessionId)&device_id=\(deviceId)&csv=\(csvString)&game=\(game)"
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    //csv submission succeeded
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    static func updatePassword(email:String, password:String, newPassword:String, finalCallBack:(success:Bool, err:String?)->()) {
        let apiExtension = "updatePassword"
        let deviceId = loadDeviceId()
        var tokenString = ""
        if let token = loadToken() { //only mobile
            tokenString = "token=\(token)"
        }
        let arguments = "email=\(email)&password=\(password)&newpassword=\(newPassword)&\(tokenString)&\(deviceId)" // mobile version
        //let arguments = "email=\(email)&password=\(password)&newpassword=\(newPassword)&\(diString)" // osx version
        postRequest(arguments, apiExtension: apiExtension, responseHandler: {(responseJSON:AnyObject!) in
            var success:Bool = false
            var err:String? = nil
            
            if let json = responseJSON as? Dictionary<String, AnyObject> {
                success = self.getIntFrom(json, key: "success") != 0
                if !success {
                    err = self.getStringFrom(json, key: "error")
                } else {
                    let retDI = self.getStringFrom(json, key: "device_id")
                    if retDI != ""{
                        self.saveDeviceId(retDI)
                    }
                    self.sessionId = self.getStringFrom(json, key: "session_token")
                }
            } else {
                println("json parse fail")
            }
            
            finalCallBack(success: success, err: err)
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    static func saveToken(token:String) {
        saveSingle(tokenKey, value: token)
    }
    
    static func loadToken() -> (String?){
        return loadSingle(tokenKey) as? String
    }
    
    private static func saveDeviceId(deviceId:String) {
        saveSingle(deviceIdKey, value: deviceId)
    }
    
    private static func loadDeviceId() -> (String?){
        return loadSingle(deviceIdKey) as? String
    }
    
    
    /**
    input: A String containing the attribute name
    output: N/A
    description: Saves attribute to disk
    */
    private class func saveSingle(attribute:String, value:AnyObject) {
        let entity = "Singles"
        let managedContext = (NSApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:entity)
        
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            if results.count > 0 {
                for result in results {
                    result.setValue(value, forKey:attribute)
                }
                var error2: NSError?
                if !managedContext.save(&error2) {
                    println("saveSingle1 Could not save \(error2), \(error2?.userInfo)")
                }
            } else {
                //-----
                let entityDesc =  NSEntityDescription.entityForName(entity,
                    inManagedObjectContext:
                    managedContext)
                
                let managedObject = NSManagedObject(entity: entityDesc!,
                    insertIntoManagedObjectContext:managedContext)
                
                managedObject.setValue(value, forKey: attribute)
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        
        
        
        var error2: NSError?
        if !managedContext.save(&error2) {
            println("saveSingle2 Could not save \(error2), \(error2?.userInfo)")
        }
        
    }
    
    
    
    /**
    input: the attribute name
    output: An object representing the attribute
    description: Loads attribute from disk
    */
    private class func loadSingle(attribute:String) -> AnyObject? {
        println("loading \(attribute) for Singles")
        let entity = "Singles"
        let managedContext = (NSApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
        //2
        let fetchRequest = NSFetchRequest(entityName:entity)
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
        if let results = fetchedResults {
            if results.count > 0 {
                println("found entries")
                println("\(results[0].valueForKey(attribute))")
                return results[0].valueForKey(attribute)
            } else {
                println("no results")
                return nil
            }
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            return nil
        }
        
    }
    
    
}















