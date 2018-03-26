//
//  SelectServer.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

func fetchServers(store: SEStore) -> SEAction {
    let servers = DatabaseManager.servers?.flatMap { dict -> SEServer? in
        guard
            let name = dict[ServerPersistKeys.serverName],
            let host = URL(string: dict[ServerPersistKeys.serverURL] ?? "")?.httpServerURL()?.absoluteString,
            let userId = dict[ServerPersistKeys.userId],
            let token = dict[ServerPersistKeys.token],
            let iconUrl = dict[ServerPersistKeys.serverIconURL]
        else {
            return nil
        }

        return SEServer(name: name, host: host, userId: userId, token: token, iconUrl: iconUrl)
    } ?? []

    return .setServers(servers)
}

func fetchRooms(store: SEStore) -> SEAction {
    guard let realm = DatabaseManager.databaseInstace(index: store.state.selectedServerIndex) else { return .setRooms([]) }
    let rooms = Array(realm.objects(Subscription.self).map(Subscription.init))
    return .setRooms(rooms)
}

func selectServer(store: SEStore, serverIndex: Int) {
    store.dispatch(.selectServerIndex(serverIndex))
    store.dispatch(fetchRooms)
}

func selectInitialServer(store: SEStore) -> SEAction? {
    store.dispatch(fetchServers)
    selectServer(store: store, serverIndex: 0)
    return nil
}
