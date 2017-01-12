//
//  SocketHandlers.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import RealmSwift
import SwiftyJSON
import Bugsnag

extension SocketManager {

    func handleMessage(_ response: JSON, socket: WebSocket) {
        guard let result = SocketResponse(response, socket: socket) else { return }

        guard !result.isError() else {
            return handleError(result, socket: socket)
        }

        guard let message = result.msg else {
            return Log.debug("Msg is invalid: \(result.result)")
        }

        switch message {
            case .Connected: return handleConnectionMessage(result, socket: socket)
            case .Ping: return handlePingMessage(result, socket: socket)
            case .Changed, .Added, .Removed: return handleModelUpdates(result, socket: socket)
            case .Error, .Updated, .Unknown: break
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
    }

    fileprivate func handlePingMessage(_ result: SocketResponse, socket: WebSocket) {
        SocketManager.send(["msg": "pong"])
    }

    fileprivate func handleError(_ result: SocketResponse, socket: WebSocket) {
        let error = result.result["error"]

        let exception = NSException(name: NSExceptionName(rawValue: error["error"].string ?? "Unknown"),
                                    reason: error["reason"].string ?? "No reason",
                                    userInfo: nil)

        Bugsnag.notify(exception)
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
                if msg == .Added || msg == .Changed {
                    let user = Realm.getOrCreate(User.self, primaryKey: identifier, values: fields)
                    Realm.update(user)
                }

                if msg == .Removed {
                    let user = Realm.getOrCreate(User.self, primaryKey: identifier, values: fields)

                    Realm.execute({ (realm) in
                        user.status = .offline
                        realm.add(user, update: true)
                    })
                }
            case "subscriptions":
                if msg == .Added || msg == .Changed {
                    let object = Realm.getOrCreate(Subscription.self, primaryKey: identifier, values: fields)
                    Realm.update(object)
                }

                if msg == .Removed {
                    let object = Realm.getOrCreate(Subscription.self, primaryKey: identifier, values: fields)
                    Realm.delete(object)
                }

            default: break
            }
        }
    }
}
