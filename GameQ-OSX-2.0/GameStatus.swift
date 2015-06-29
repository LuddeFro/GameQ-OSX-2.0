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
    case NoGame = "NO GAME ACTIVE"
}