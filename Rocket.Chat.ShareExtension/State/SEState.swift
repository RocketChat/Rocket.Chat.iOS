//
//  SEState.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SEAction {
    case setContent([SEContent])
    case setContentValue(SEContent, index: Int)
    case setServers([SEServer])
    case selectServerIndex(Int)
    case setRooms([Subscription])
    case setSearchRooms(SESearchState)
    case setCurrentRoom(Subscription)
    case makeSceneTransition(SESceneTransition)
    case setScenes([SEScene])
    case finish
}

struct SEState {
    var servers: [SEServer] = []
    var selectedServerIndex: Int = 0
    var rooms: [Subscription] = []
    var currentRoom = Subscription()
    var searchRooms: SESearchState = .none
    var content: [SEContent] = []
    var navigation = SENavigation(scenes: [], sceneTransition: .none)

    var displayedRooms: [Subscription] {
        let displayedRooms: [Subscription]
        switch searchRooms {
        case .none:
            displayedRooms = rooms
        case .searching(let search):
            let search = search.lowercased()
            displayedRooms = rooms.filter {
                $0.fname.lowercased().contains(search) || $0.name.lowercased().contains(search)
            }
        case .started:
            displayedRooms = rooms
        }
        return displayedRooms.sorted(by: { $0.name < $1.name })
    }

    var isSubmittingContent: Bool {
        return content.contains(where: {
            if case .sending = $0.status {
                return true
            }

            return false
        })
    }
}
