//
//  Status.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

enum Status {
    case Offline
    case Online
    case InLobby
    case InQueue
    case GameReady
    case InGame
}

enum Game {
    
    case Dota2
    case HoN
    case CSGO
    case HOTS
    case LoL
    case NoGame
}

class Encoding {
    
    static func getStringFromGame(game:Game) -> String{
        switch game{
        case .Dota2: return "Dota 2"
        case .HoN: return "Heroes of Newerth"
        case .CSGO: return "Counter Strike Global Offensive"
        case .HOTS: return "Heroes of The Storm"
        case .LoL: return "League of Legends"
        case .NoGame: return "No Game Active"
        }
    }
    
    static func getIntFromGame(game:Game) -> Int{
        switch game{
        case .NoGame: return 0
        case .Dota2: return 1
        case .HoN: return 2
        case .CSGO: return 3
        case .HOTS: return 4
        case .LoL: return 5
        }
    }
    
    static func getStringFromGameStatus(game:Game, status:Status) -> String{
        
        switch game {
        case .Dota2:
            switch status{
            case .Offline: return "Offline"
            case .Online: return  "Online"
            case .InLobby: return "In Game Lobby"
            case .InQueue: return "Finding Match"
            case .GameReady: return "Your Match is Ready"
            case .InGame:return "In Match"
            }
        case .HoN:
            switch status{
            case .Offline: return "Offline"
            case .Online: return  "Online"
            case .InLobby: return "In Game Lobby"
            case .InQueue: return "Finding Match"
            case .GameReady: return "Your Match is Ready"
            case .InGame:return "In Match"
            }
        case .CSGO:
            switch status{
            case .Offline: return "Offline"
            case .Online: return  "Online"
            case .InLobby: return "In Game Lobby"
            case .InQueue: return "Finding Match"
            case .GameReady: return "Your Match is Ready"
            case .InGame:return "In Match"
            }
        case .HOTS:
            switch status{
            case .Offline: return "Offline"
            case .Online: return  "Online"
            case .InLobby: return "In Game Lobby"
            case .InQueue: return "Finding Match"
            case .GameReady: return "Your Match is Ready"
            case .InGame:return "In Match"
            }
        case .LoL:
            switch status{
            case .Offline: return "Offline"
            case .Online: return  "Online"
            case .InLobby: return "In Game Lobby"
            case .InQueue: return "Searching for Match"
            case .GameReady: return "Your Match is Ready"
            case .InGame:return "In Match"
            }
            
        case .NoGame:
            switch status{
            case .Offline: return "Offline"
            case .Online: return  "Online"
            case .InLobby: return "Something went wrong"
            case .InQueue: return "Something went wrong"
            case .GameReady: return "Something went wrong"
            case .InGame:return "Something went wrong"
            }
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