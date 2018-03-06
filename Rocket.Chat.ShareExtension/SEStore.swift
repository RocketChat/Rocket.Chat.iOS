//
//  SEDatabase.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEServer {
    let name: String
    let host: String
    let userId: String
    let token: String
}

struct SEState {
    var servers: [SEServer] = []
    var selectedServerIndex: Int = 0
    var rooms: [Subscription] = []
    var currentRoom = Subscription()
    var composeText = ""
    var navigation = SENavigation(scenes: [], sceneTransition: .none)
}

enum SEAction {
    case setComposeText(String)
    case setServers([SEServer])
    case selectServerIndex(Int)
    case setRooms([Subscription])
    case setCurrentRoom(Subscription)
    case makeSceneTransition(SESceneTransition)
    case setScenes([SEScene])
}

protocol SEStoreSubscriber: class {
    func stateUpdated(_ state: SEState)
}

final class SEStore {
    private(set) var state = SEState()
    private(set) var subscribers = [SEStoreSubscriber]()

    func dispatch(_ action: SEAction) {
        switch action {
        case .setComposeText(let text):
            state.composeText = text
        case .setServers(let servers):
            state.servers = servers
        case .selectServerIndex(let index):
            state.selectedServerIndex = index
        case .setRooms(let rooms):
            state.rooms = rooms
        case .setCurrentRoom(let room):
            state.currentRoom = room
        case .setScenes(let scenes):
            state.navigation.scenes = scenes
        case .makeSceneTransition(let transition):
            state.navigation.makeTransition(transition)
        }

        notifySubscribers()
    }

    func dispatch(_ actionCreator: (SEStore) -> SEAction) {
        dispatch(actionCreator(self))
    }

    func subscribe(_ subscriber: SEStoreSubscriber) {
        guard !subscribers.contains(where: { $0 === subscriber }) else {
            return
        }

        subscribers.append(subscriber)
        subscriber.stateUpdated(state)
    }

    func unsubscribe(_ subscriber: SEStoreSubscriber) {
        guard let index = subscribers.index(where: { $0 === subscriber }) else {
            return
        }

        subscribers.remove(at: index)
    }

    func notifySubscribers() {
        subscribers.forEach {
            $0.stateUpdated(state)
        }
    }

    func clearSubscribers() {
        subscribers.removeAll()
    }
}

let store = SEStore()
