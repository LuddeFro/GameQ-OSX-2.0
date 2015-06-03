//
//  Status.swift
//  gameq-data-gatherer
//
//  Created by Fabian Wikström on 5/25/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

import Foundation

enum Status:String {
    case Offline = "Offline"
    case Online = "Online"
    case InLobby = "InLobby"
    case InQueue = "InQueue"
    case GameReady = "GameReady"
    case InGame = "InGame"
}