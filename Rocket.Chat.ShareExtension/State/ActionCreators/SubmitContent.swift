//
//  SubmitContent.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/13/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

fileprivate extension SEStore {
    var contentRequests: [(Int, APIRequest)] {
        return store.state.content.map { content -> APIRequest in
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
        }.enumerated().map { ($0, $1) }
    }

    var api: API? {
        let server = state.servers[state.selectedServerIndex]

        let api = API(host: "https://\(server.host)", version: Version(0, 60, 0))
        api?.userId = server.userId
        api?.authToken = server.token

        return api
    }
}

func submitFiles(store: SEStore, completion: @escaping (() -> Void)) {
    var fileRequests = store.contentRequests.flatMap { index, request -> (index: Int, request: UploadRequest)? in
        guard let request = request as? UploadRequest else {
            return nil
        }

        return (index, request)
    }

    func requestNext() {
        guard let (index, request) = fileRequests.popLast() else {
            completion()
            return
        }

        store.dispatch(.setContentStatus(index: index, status: .sending))

        store.api?.fetch(request, succeeded: { result in
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

            requestNext()
        })
    }

    requestNext()
}

func submitMessages(store: SEStore, completion: @escaping (() -> Void)) {
    var messageRequests = store.contentRequests.flatMap { index, request -> (index: Int, request: SendMessageRequest)? in
        guard let request = request as? SendMessageRequest else {
            return nil
        }

        return (index, request)
    }

    func requestNext() {
        guard let (index, request) = messageRequests.popLast() else {
            completion()
            return
        }

        store.dispatch(.setContentStatus(index: index, status: .sending))

        store.api?.fetch(request, succeeded: { _ in
            DispatchQueue.main.async {
                store.dispatch(.setContentStatus(index: index, status: .succeeded))
            }

            requestNext()
        }, errored: { error in
            DispatchQueue.main.async {
                store.dispatch(.setContentStatus(index: index, status: .errored("\(error)")))
            }

            requestNext()
        })
    }

    requestNext()
}
