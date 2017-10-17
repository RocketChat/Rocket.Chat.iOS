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
import Crashlytics

extension SocketManager {

    func handleMessage(_ response: JSON, socket: WebSocket) {
        guard let result = SocketResponse(response, socket: socket) else { return }

        guard let message = result.msg else {
            return Log.debug("Msg is invalid: \(result.result)")
        }

        switch message {
        case .connected:
            return handleConnectionMessage(result, socket: socket)
        case .ping:
            return handlePingMessage(result, socket: socket)
        case .changed, .added, .removed:
            return handleModelUpdates(result, socket: socket)
        case .updated, .unknown:
            break
        case .error:
            handleError(result, socket: socket)
        }

        // Call completion block
        guard let identifier = result.id,
              let completion = queue[identifier] else { return }
        let messageCompletion = completion as MessageCompletion
        messageCompletion(result)
    }

    fileprivate func handleConnectionMessage(_ result: SocketResponse, socket: WebSocket) {
        internalConnectionHandler?(socket, true)
        internalConnectionHandler = nil

        for (_, handler) in connectionHandlers {
            handler.socketDidConnect(socket: self)
        }
    }

    fileprivate func handlePingMessage(_ result: SocketResponse, socket: WebSocket) {
        SocketManager.send(["msg": "pong"])
    }

    fileprivate func handleError(_ result: SocketResponse, socket: WebSocket) {
        // Do nothing?
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
        if let collection = result.collection {
            guard let msg = result.msg else { return }
            guard let identifier = result.result["id"].string else { return }
            let fields = result.result["fields"]

            switch collection {
            case "users":
                User.handle(msg: msg, primaryKey: identifier, values: fields)
            case "subscriptions":
                Subscription.handle(msg: msg, primaryKey: identifier, values: fields)
            default:
                break
            }
        }
    }
}
