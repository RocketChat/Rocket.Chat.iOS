//
//  SEDatabase.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

private func getServers() -> [(name: String, host: String)] {
    return DatabaseManager.servers?.flatMap {
        guard
            let name = $0[ServerPersistKeys.serverName],
            let host = URL(string: $0[ServerPersistKeys.serverURL] ?? "")?.host
        else {
            return nil
        }

        return (name, host)
    } ?? []
}

// swiftlint:disable large_tuple
private func getRooms(serverIndex: Int) -> (favorites: [String], channels: [String], groups: [String], directMessages: [String]) {
    guard let realm = DatabaseManager.databaseInstace(index: serverIndex) else { return ([], [], [], [])}

    let subscriptions = Array(realm.objects(Subscription.self))

    let favorites = subscriptions.filter { $0.favorite }.map { $0.name }
    let channels = subscriptions.filter { $0.type == .channel }.map { $0.name }
    let groups = subscriptions.filter { $0.type == .group }.map { $0.name }
    let directMessages = subscriptions.filter { $0.type == .directMessage }.map { $0.name }

    return (favorites, channels, groups, directMessages)
}

protocol SEStoreSubscriber: class {
    func storeUpdated(_ store: SEStore)
}

final class SEStore {
    var servers = getServers() {
        didSet {
            notifySubscribers()
        }
    }

    var selectedServerIndex: Int = 0 {
        didSet {
            rooms = getRooms(serverIndex: selectedServerIndex)
            notifySubscribers()
        }
    }

    var scenes: [SEScene] = [.rooms] {
        didSet {
            notifySubscribers()
        }
    }

    var sceneTransition: SESceneTransition = .none {
        didSet {
            notifySubscribers()
        }
    }

    var rooms = getRooms(serverIndex: 0) {
        didSet {
            notifySubscribers()
        }
    }

    var composeText = "" {
        didSet {
            notifySubscribers()
        }
    }

    private var subscribers = [SEStoreSubscriber]()

    func subscribe(_ subscriber: SEStoreSubscriber) {
        guard !subscribers.contains(where: { $0 === subscriber }) else {
            return
        }

        subscribers.append(subscriber)
        subscriber.storeUpdated(self)
    }

    func unsubscribe(_ subscriber: SEStoreSubscriber) {
        guard let index = subscribers.index(where: { $0 === subscriber }) else {
            return
        }

        subscribers.remove(at: index)
    }

    func notifySubscribers() {
        subscribers.forEach {
            $0.storeUpdated(self)
        }
    }
}

let store = SEStore()
