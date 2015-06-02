//
//  main.swift
//  GameQ-Data-Gatherer
//
//  Created by Ludvig Fröberg on 19/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

class ShitDoer:NSObject{
    
    static func doShit(){
        
        println()
        println("**********************************")
        println("Welcome to the GameQ Data Gatherer")
        println("**********************************")
        println()
        
        let availableGames = ["hon", "csgo", "dota", "hots", "sc2", "overwatch", "lol", "tf2", "hs", "wow", "smite", "ta", "wot", "gw2", "swtor"]
        let dotaFilter = "udp src portrange 27000-28999 or udp dst port 27005 or udp src port 4380"
        let csgoFilter = "udp src portrange 27000-28999 or udp dst port 27005"
        let honFilter = "udp dst portrange 11235-11335 or tcp dst port 11031"
        let hotsFilter = "udp dst portrange 1119-1120 or udp dst port 6113 or udp dst port 3724 or tcp dst portrange 1119-1120 or tcp dst port 6113 or tcp dst port 3724"
        let sc2Filter = "udp dst portrange 1119-1120 or udp dst port 6113 or udp dst port 3724 or tcp dst portrange 1119-1120 or tcp dst port 6113 or tcp dst port 3724"
        let hsFilter = "udp dst port 1119 or udp dst port 3724 or tcp dst port 1119 or tcp dst port 3724"
        let wowFilter = "udp dst port 1119 or udp dst port 3724 or tcp dst port 1119 or tcp dst port 3724"
        let overwatchFilter = ""
        let lolFilter = "udp dst portrange 5000-5500 or tcp dst portrange 8393-8400 or tcp dst port 2099 or tcp dst portrange 5222-5223"
        let tf2Filter = "tcp dst portrange 27014-27050 or udp dst portrange 3478-4380 or udp dst portrange 27000-27030 or udp src port 27005"
        let smiteFilter = "tcp dst portrange 9000-9999 or udp dst portrange 9002-9999"
        let taFilter = "tcp dst portrange 9000-9999 or udp dst portrange 9002-9999"
        let wotFilter = "udp dst portrange 20013-20014 or udp dst port 20018 or udp dst portrange 32801-32825"
        let gw2Filter = "tcp port 6112 or tcp port 6600"
        let swtorFilter = "tcp dst port 8995 or tcp dst portrange 12000-12999 or tcp dst portrange 20000-30000"
        
        let filters:Dictionary<String, String> = ["hon": honFilter, "csgo": csgoFilter, "dota":dotaFilter, "sc2":sc2Filter, "overwatch":overwatchFilter, "lol":lolFilter, "tf2":tf2Filter, "hs":hsFilter, "wow":wowFilter, "smite":smiteFilter, "ta":taFilter, "wot":wotFilter, "gw2":gw2Filter, "swtor":swtorFilter]
        
        let descriptions:Dictionary<String, String> = ["hon": "Heroes of Newerth", "csgo": "Counter Strike: Global Offensive", "dota": "Dota2", "sc2":"StarCraft II", "overwatch": "Overwatch", "lol": "League of Legends", "tf2": "Team Fortress 2", "hs": "Hearthstone", "wow": "World of Warcraft", "smite": "Smite", "ta": "Tribes Ascend", "wot": "World of Tanks", "gw2": "Guild Wars 2", "swtor": "Star Wars The Old Republic"]
        
        let availableFilters = filters.keys.array
        
        
        while true {
            println("Thank you for helping us improve GameQ!!!")
            println("Choose a game: \(availableGames)")
            println("If you are unsure of what the game abbreviations mean, prepend the abbreviation with a dash to get a full description... for example to write out the full name of the abbreviation 'csgo' one would type '-csgo'")
            while true {
                var input = DataHandler.prompt()
                if input.substringToIndex(advance(input.startIndex, 1)) == "-" {
                    var matches = false
                    for game in availableGames {
                        if game == input.substringFromIndex(advance(input.startIndex, 1)) {
                            matches = true
                        }
                    }
                    if matches {
                        println("\(input.substringFromIndex(advance(input.startIndex, 1))) refers to: \(descriptions[input.substringFromIndex(advance(input.startIndex, 1))])")
                    } else {
                        println("no such abbreviation exists")
                    }
                } else {
                    var matches = false
                    for game in availableGames {
                        if game == input {
                            matches = true
                        }
                    }
                    if !matches {
                        println("Unrecognized game, please choose one of the following: \(availableGames)")
                    } else {
                        DataHandler.Static.game = input
                        break
                    }
                }
            }
            
            
            println("Insert filter or choose a predefined filter for your game by typeing 'pre'")
            
            var filter:String = DataHandler.prompt()
            if filter == "pre" {
                filter = filters[DataHandler.Static.game]!
            }
            
            println("filter set: \(filter)")
            println("Insert Capture Size:")
            
            var capSizeString = DataHandler.prompt()
            
            var capSize:Int = NSString(string: capSizeString).integerValue
            
            println("capSize set: \(capSize)")
            DotaDetector.startDetection()
            
            let capString:String = "cap"
            let breakString:String = "break"
            let resetString:String = "reset"
            
            println()
            println("----------------------------")
            println("Starting Capture!")
            println("To save a capture type in '\(capString)', to reset a capture type '\(resetString)', to stop and change settings type in '\(breakString)', to exit the program simply close this terminal!")
            println("----------------------------")
            
            while true {
                
                var input = DataHandler.prompt()
                if (input == capString) {
                    DotaDetector.stopDetection()
                    println("Choose a file name:")
                    var filename = DataHandler.prompt()
                    println("Filename: \(filename)")
                    DotaReader.save()
                    println("Your data has been saved!")
                    DotaReader.packetQueue.removeAll(keepCapacity: true)
                    println("Continue Capture? 'yes'/'no'")
                    var input2 = DataHandler.prompt()
                    if input2 == "yes" {
                        println("Great! Restarting Capture!")
                        DotaDetector.startDetection()
                    } else {
                        break
                    }
                } else if input == breakString {
                    DotaDetector.stopDetection()
                    DotaReader.packetQueue.removeAll(keepCapacity: true)
                    println("interupted capture!")
                    break
                } else if input == resetString {
                    DotaReader.packetQueue.removeAll(keepCapacity: true)
                    println("reset capture!")
                }
            }
        }
    }
}







