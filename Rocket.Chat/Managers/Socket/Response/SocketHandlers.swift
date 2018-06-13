//
//  SocketHandlers.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

extension SocketManager {

    func handleMessage(_ response: JSON, socket: WebSocket) {
        SocketManager.jsonParseQueue.async {

            guard let result = SocketResponse(response, socket: socket) else { return }

            guard let message = result.msg else {
                return Log.debug("Msg is invalid: \(result.result)")
            }

            DispatchQueue.main.async {
                switch message {
                case .connected:
                    return self.handleConnectionMessage(result, socket: socket)
                case .ping:
                    return self.handlePingMessage(result, socket: socket)
                case .changed, .added, .removed:
                    return self.handleModelUpdates(result, socket: socket)
                case .updated, .unknown:
                    break
                case .error:
                    self.handleError(result, socket: socket)
                }

                // Call completion block
                guard let identifier = result.id,
                    let completion = self.queue[identifier] else { return }
                let messageCompletion = completion as MessageCompletion
                messageCompletion(result)
            }
        }
    }

    fileprivate func handleConnectionMessage(_ result: SocketResponse, socket: WebSocket) {
        internalConnectionHandler?(socket, true)
        internalConnectionHandler = nil
        state = .connected
    }

    fileprivate func handlePingMessage(_ result: SocketResponse, socket: WebSocket) {
        SocketManager.send(["msg": "pong"])
    }

    fileprivate func handleError(_ result: SocketResponse, socket: WebSocket) {
        let error = SocketError(json: result.result["error"])
        Log.debug("[ERROR][SocketManager]: \(error.message)")
    }

    fileprivate func handleEventSubscription(_ result: SocketResponse, socket: WebSocket) {
        let handlers = events[result.event ?? ""]
        handlers?.forEach({ (handler) in
            handler(result)
        })
    }

    fileprivate func handleModelUpdates(_ result: SocketResponse, socket: WebSocket) {
        if result.event != nil {
            return handleEventSubscription(result, socket: socket)
        }

        // Handle model updates
        SocketManager.jsonParseQueue.async {
            if let collection = result.collection {
                guard let msg = result.msg else { return }
                guard let identifier = result.result["id"].string else { return }
                let fields = result.result["fields"]

                DispatchQueue.main.async {
                    switch collection {
                    case "users":
                        User.handle(msg: msg, primaryKey: identifier, values: fields)
                    case "subscriptions":
                        Subscription.handle(msg: msg, primaryKey: identifier, values: fields)
                    case "meteor_accounts_loginServiceConfiguration":
                        LoginService.handle(msg: msg, primaryKey: identifier, values: fields)
                    default:
                        break
                    }
                }
            }
        }
    }
}
