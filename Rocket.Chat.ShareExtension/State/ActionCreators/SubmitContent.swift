//
//  SubmitContent.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/13/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

fileprivate extension SEStore {
    enum Request {
        case file(UploadMessageRequest)
        case text(SendMessageRequest)
    }

    var contentRequests: [(Int, Request)] {
        return store.state.content.map { content -> Request in
            switch content.type {
            case .file(let file):
                return .file(UploadMessageRequest(
                    roomId: store.state.currentRoom.rid,
                    data: file.data,
                    filename: file.name,
                    mimetype: file.mimetype,
                    description: file.description
                ))
            case .text(let text):
                return .text(SendMessageRequest(
                    id: "ios_se_\(String.random(10))",
                    roomId: store.state.currentRoom.rid,
                    text: text
                ))
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
    var fileRequests = store.contentRequests.compactMap { index, request -> (index: Int, request: UploadMessageRequest)? in
        switch request {
        case .file(let request):
            return (index, request)
        default:
            return nil
        }
    }

    func requestNext() {
        DispatchQueue.main.async {
            guard let (index, request) = fileRequests.popLast() else {
                completion()
                return
            }

            let content = store.state.content[index]

            store.dispatch(.setContentValue(content.withStatus(.sending), index: index))

            let task = store.api?.fetch(request) { response in

                switch response {
                case .resource(let resource):
                    let content = store.state.content[index]
                    DispatchQueue.main.async {
                        if let error = resource.error {
                                store.dispatch(.setContentValue(content.withStatus(.errored(error)), index: index))
                        } else {
                                store.dispatch(.setContentValue(content.withStatus(.succeeded), index: index))
                        }
                    }
                case .error(let error):
                    let content = store.state.content[index]
                    DispatchQueue.main.async {
                        store.dispatch(.setContentValue(content.withStatus(.errored("\(error)")), index: index))
                    }
                }

                requestNext()
            }

            urlTasks.append(task)
        }
    }

    requestNext()
}

func submitMessages(store: SEStore, completion: @escaping (() -> Void)) {
    var messageRequests = store.contentRequests.compactMap { index, request -> (index: Int, request: SendMessageRequest)? in
        switch request {
        case .text(let request):
            return (index, request)
        default:
            return nil
        }
    }

    func requestNext() {
        guard let (index, request) = messageRequests.popLast() else {
            completion()
            return
        }

        let content = store.state.content[index]
        store.dispatch(.setContentValue(content.withStatus(.sending), index: index))

        let task = store.api?.fetch(request) { response in
            switch response {
            case .resource:
                DispatchQueue.main.async {
                    let content = store.state.content[index]
                    store.dispatch(.setContentValue(content.withStatus(.succeeded), index: index))
                }
            case .error(let error):
                DispatchQueue.main.async {
                    let content = store.state.content[index]
                    store.dispatch(.setContentValue(content.withStatus(.errored("\(error)")), index: index))
                }
            }
            requestNext()
        }

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
