//
//  Status.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

enum Status:String {
    case Offline = "OFFLINE"
    case Online = "ONLINE"
    case InLobby = "IN LOBBY"
    case InQueue = "IN QUEUE"
    case GameReady = "GAME READY"
    case InGame = "IN GAME"
}

enum Game:String {
    
    case Dota = "DOTA2"
    case HoN = "HEROES OF NEWERTH"
    case CSGO = "CSGO"
    case HOTS = "HOTS"
    case LoL = "LoL"
    case NoGame = "NO GAME ACTIVE"
}

 class Encoding {
    
    static func getStringFromGame(game:Game) -> String{
        switch game{
        case .Dota: return "DOTA2"
        case .HoN: return "HEROES OF NEWERTH"
        case .CSGO: return "CSGO"
        case .HOTS: return "HOTS"
        case .LoL: return "LoL"
        case .NoGame: return "NO GAME ACTIVE"
        }
    }
    
    static func getIntFromGame(game:Game) -> Int{
        switch game{
        case .NoGame: return 0
        case .Dota: return 1
        case .HoN: return 2
        case .CSGO: return 3
        case .HOTS: return 4
        case .LoL: return 5
        }
    }
    
    static func getStringFromStatus(status:Status) -> String{
        switch status{
        case .Offline: return "OFFLINE"
        case .Online: return  "ONLINE"
        case .InLobby: return "IN LOBBY"
        case .InQueue: return "IN QUEUE"
        case .GameReady: return "GAME READY"
        case .InGame:return "IN GAME"
        }
    }
    
    static func getIntFromStatus(status:Status) -> Int{
        switch status{
        case .Offline: return 1
        case .Online: return  2
        case .InLobby: return 3
        case .InQueue: return 4
        case .GameReady: return 5
        case .InGame:return 6
        }
    }
}