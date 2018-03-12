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

func submitContent(store: SEStore) {
    let requests = store.state.content.map { content -> APIRequest in
        switch content.type {
        case .file(let file):
            return UploadRequest(
                roomId: store.state.currentRoom.rid,
                data: file.data,
                filename: file.name,
                mimetype: file.mimetype
            )
        case .text(let text):
            return SendMessageRequest(
                id: "ios_se_\(String.random(10))",
                roomId: store.state.currentRoom.rid,
                text: text
            )
        }
    }.enumerated()

    let server = store.state.servers[store.state.selectedServerIndex]

    let api = API(host: "https://\(server.host)", version: Version(0, 60, 0))
    api?.userId = server.userId
    api?.authToken = server.token

    var fileRequests = requests.flatMap { index, request -> (index: Int, request: UploadRequest)? in
        guard let request = request as? UploadRequest else {
            return nil
        }

        return (index, request)
    }

    var messageRequests = requests.flatMap { index, request -> (index: Int, request: SendMessageRequest)? in
        guard let request = request as? SendMessageRequest else {
            return nil
        }

        return (index, request)
    }

    func requestNext() {
        guard let (index, request) = fileRequests.popLast() else {
            DispatchQueue.main.async {
                store.dispatch(.finish)
            }
            return
        }

        store.dispatch(.setContentStatus(index: index, status: .sending))

        api?.fetch(request, succeeded: { result in
            DispatchQueue.main.async {
                if let error = result.error {
                    store.dispatch(.setContentStatus(index: index, status: .errored(error)))
                } else {
                    store.dispatch(.setContentStatus(index: index, status: .succeeded))
                }
            }

            requestNext()
        }, errored: { error in
            DispatchQueue.main.async {
                store.dispatch(.setContentStatus(index: index, status: .errored("\(error)")))
            }
        })
    }

    requestNext()
}
