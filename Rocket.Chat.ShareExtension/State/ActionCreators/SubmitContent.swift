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
                return UploadMessageRequest(
                    roomId: store.state.currentRoom.rid,
                    data: file.data,
                    filename: file.name,
                    mimetype: file.mimetype,
                    description: file.description
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

        let api = API(host: server.host, version: Version(0, 60, 0))
        api?.userId = server.userId
        api?.authToken = server.token

        return api
    }
}

var urlTasks: [URLSessionTask?] = []

func submitFiles(store: SEStore, completion: @escaping (() -> Void)) {
    var fileRequests = store.contentRequests.flatMap { index, request -> (index: Int, request: UploadMessageRequest)? in
        guard let request = request as? UploadMessageRequest else {
            return nil
        }

        return (index, request)
    }

    func requestNext() {
        DispatchQueue.main.async {
            guard let (index, request) = fileRequests.popLast() else {
                completion()
                return
            }

            let content = store.state.content[index]

            store.dispatch(.setContentValue(content.withStatus(.sending), index: index))

            let task = store.api?.fetch(request, succeeded: { result in
                DispatchQueue.main.async {
                    let content = store.state.content[index]
                    if let error = result.error {
                        store.dispatch(.setContentValue(content.withStatus(.errored(error)), index: index))
                    } else {
                        store.dispatch(.setContentValue(content.withStatus(.succeeded), index: index))
                    }
                }

                requestNext()
            }, errored: { error in
                DispatchQueue.main.async {
                    let content = store.state.content[index]
                    store.dispatch(.setContentValue(content.withStatus(.errored("\(error)")), index: index))
                }

                requestNext()
            })

            urlTasks.append(task)
        }
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

        let content = store.state.content[index]
        store.dispatch(.setContentValue(content.withStatus(.sending), index: index))

        let task = store.api?.fetch(request, succeeded: { _ in
            DispatchQueue.main.async {
                let content = store.state.content[index]
                store.dispatch(.setContentValue(content.withStatus(.succeeded), index: index))
            }

            requestNext()
        }, errored: { error in
            DispatchQueue.main.async {
                let content = store.state.content[index]
                store.dispatch(.setContentValue(content.withStatus(.errored("\(error)")), index: index))
            }

            requestNext()
        })

        urlTasks.append(task)
    }

    requestNext()
}

func submitContent(_ store: SEStore) -> SEAction? {
    submitMessages(store: store) {
        submitFiles(store: store) {
            DispatchQueue.main.async {
                store.dispatch(.makeSceneTransition(.push(.report)))
            }
        }
    }

    return nil
}

func cancelSubmittingContent(_ store: SEStore) -> SEAction? {
    urlTasks.forEach {
        $0?.cancel()
    }

    urlTasks.removeAll()

    return nil
}
