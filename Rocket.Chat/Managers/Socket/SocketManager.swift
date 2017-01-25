//
//  SocketManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import Starscream
import SwiftyJSON
import RealmSwift

public typealias RequestCompletion = (JSON?, Bool) -> Void
public typealias MessageCompletion = (SocketResponse) -> Void
public typealias SocketCompletion = (WebSocket?, Bool) -> Void
public typealias MessageCompletionObject <T: Object> = (T) -> Void
public typealias MessageCompletionObjectsList <T: Object> = ([T]) -> Void

protocol SocketConnectionHandler {
    func socketDidConnect(socket: SocketManager)
    func socketDidDisconnect(socket: SocketManager)
}

class SocketManager {

    static let sharedInstance = SocketManager()

    var serverURL: URL?

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var events: [String: [MessageCompletion]] = [:]

    internal var internalConnectionHandler: SocketCompletion?
    internal var connectionHandlers: [String: SocketConnectionHandler] = [:]

    // MARK: Connection

    static func connect(_ url: URL, completion: @escaping SocketCompletion) {
        sharedInstance.serverURL = url
        sharedInstance.internalConnectionHandler = completion

        sharedInstance.socket = WebSocket(url: url)
        sharedInstance.socket?.delegate = sharedInstance
        sharedInstance.socket?.pongDelegate = sharedInstance

        sharedInstance.socket?.connect()
    }

    static func disconnect(_ completion: @escaping SocketCompletion) {
        sharedInstance.internalConnectionHandler = completion
        sharedInstance.socket?.disconnect()
    }

    // MARK: Messages

    static func send(_ object: [String: Any], completion: MessageCompletion? = nil) {
        let identifier = String.random(50)
        var json = JSON(object)
        json["id"] = JSON(identifier)

        if let raw = json.rawString() {
            Log.debug("Socket will send message: \(raw)")

            sharedInstance.socket?.write(string: raw)

            if completion != nil {
                sharedInstance.queue[identifier] = completion
            }
        } else {
            Log.debug("JSON invalid: \(json)")
        }
    }

    static func subscribe(_ object: [String: Any], eventName: String, completion: @escaping MessageCompletion) {
        if var list = sharedInstance.events[eventName] {
            list.append(completion)
            sharedInstance.events[eventName] = list
        } else {
            self.send(object, completion: completion)
            sharedInstance.events[eventName] = [completion]
        }
    }

}

// MARK: Helpers

extension SocketManager {

    static func reconnect() {
        guard let auth = AuthManager.isAuthenticated() else { return }

        AuthManager.resume(auth, completion: { (response) in
            guard !response.isError() else {
                return
            }

            SubscriptionManager.updateSubscriptions(auth, completion: { _ in
                // TODO: Move it to somewhere else
                AuthManager.updatePublicSettings(auth, completion: { _ in

                })

                UserManager.changes()
                SubscriptionManager.changes(auth)
                PushManager.setUser(auth.userId, completion: { (response) in })
            })
        })
    }

    static func isConnected() -> Bool {
        return self.sharedInstance.socket?.isConnected ?? false
    }

}

// MARK: Connection handlers

extension SocketManager {

    static func addConnectionHandler(token: String, handler: SocketConnectionHandler) {
        sharedInstance.connectionHandlers[token] = handler
    }

    static func removeConnectionHandler(token: String) {
        sharedInstance.connectionHandlers[token] = nil
    }

}

// MARK: WebSocketDelegate

extension SocketManager: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        Log.debug("Socket (\(socket)) did connect")

        let object = [
            "msg": "connect",
            "version": "1",
            "support": ["1", "pre2", "pre1"]
        ] as [String : Any]

        SocketManager.send(object)
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.debug("[WebSocket] did disconnect with error (\(error))")

        events = [:]
        queue = [:]

        internalConnectionHandler?(socket, socket.isConnected)
        internalConnectionHandler = nil

        for (_, handler) in connectionHandlers {
            handler.socketDidDisconnect(socket: self)
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        Log.debug("[WebSocket] did receive data (\(data))")
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON.parse(text)

        // JSON is invalid
        guard json.exists() else {
            Log.debug("[WebSocket] did receive invalid JSON object: \(text)")
            return
        }

        if let raw = json.rawString() {
            Log.debug("[WebSocket] did receive JSON message: \(raw)")
        }

        self.handleMessage(json, socket: socket)
    }

}

// MARK: WebSocketPongDelegate

extension SocketManager: WebSocketPongDelegate {

    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        Log.debug("[WebSocket] did receive pong")
    }

}
