//
//  SEDatabase.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol SEStoreSubscriber: class {
    func stateUpdated(_ state: SEState)
}

final class SEStore {
    private(set) var state = SEState()
    private(set) var subscribers = [SEStoreSubscriber]()

    func dispatch(_ action: SEAction) {
        switch action {
        case .setContent(let content):
            state.content = content
        case .setContentValue(let value, let index):
            state.content[index] = value
        case .setServers(let servers):
            state.servers = servers
        case .selectServerIndex(let index):
            state.selectedServerIndex = index
        case .setRooms(let rooms):
            state.rooms = rooms
        case .setSearchRooms(let search):
            state.searchRooms = search
        case .setCurrentRoom(let room):
            state.currentRoom = room
        case .setScenes(let scenes):
            state.navigation.scenes = scenes
        case .makeSceneTransition(let transition):
            state.navigation.makeTransition(transition)
        case .finish:
            state.navigation.makeTransition(.finish)
        }

        notifySubscribers()
    }

    func dispatch(_ actionCreator: (SEStore) -> SEAction?) {
        if let action = actionCreator(self) {
            dispatch(action)
        }
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
