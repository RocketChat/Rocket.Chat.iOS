//
//  SEActionCreators.swift
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
            let host = URL(string: dict[ServerPersistKeys.serverURL] ?? "")?.host,
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

func initializeStore(store: SEStore) {
    store.dispatch(fetchServers)
    selectServer(store: store, serverIndex: 0)
}

func selectServer(store: SEStore, serverIndex: Int) {
    store.dispatch(.selectServerIndex(serverIndex))
    store.dispatch(fetchRooms)
}

func submitContent(store: SEStore) -> SEAction {
    let server = store.state.servers[store.state.selectedServerIndex]

    let request = SendMessageRequest(
        id: "ios_se_\(String.random(10))",
        roomId: store.state.currentRoom.rid,
        text: store.state.composeText
    )

    let api = API(host: "https://\(server.host)", version: Version(0, 60, 0))
    api?.userId = server.userId
    api?.authToken = server.token

    api?.fetch(request, succeeded: { _ in
        DispatchQueue.main.async {
            store.dispatch(.makeSceneTransition(.finish))
            store.dispatch(.setSubmittingContent(false))
        }
    }, errored: { _ in
        DispatchQueue.main.async {
            store.dispatch(.setSubmittingContent(false))
        }
    })

    return .setSubmittingContent(true)
}
