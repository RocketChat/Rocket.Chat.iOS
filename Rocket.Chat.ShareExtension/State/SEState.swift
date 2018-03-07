//
//  SEState.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEServer {
    let name: String
    let host: String
    let userId: String
    let token: String
}

enum SEAction {
    case setComposeText(String)
    case setServers([SEServer])
    case selectServerIndex(Int)
    case setRooms([Subscription])
    case setSearchRooms(SESearchState)
    case setCurrentRoom(Subscription)
    case makeSceneTransition(SESceneTransition)
    case setScenes([SEScene])
}

struct SEState {
    var servers: [SEServer] = []
    var selectedServerIndex: Int = 0
    var rooms: [Subscription] = []
    var currentRoom = Subscription()
    var searchRooms: SESearchState = .none
    var composeText = ""
    var navigation = SENavigation(scenes: [], sceneTransition: .none)

    var displayedRooms: [Subscription] {
        switch searchRooms {
        case .none:
            return rooms
        case .searching(let search):
            return rooms.filter { $0.fname.contains(search) || $0.name.contains(search) }
        case .started:
            return rooms
        }
    }
}
