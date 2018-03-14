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
public typealias VoidCompletion = () -> Void
public typealias MessageCompletion = (SocketResponse) -> Void
public typealias SocketCompletion = (WebSocket?, Bool) -> Void
public typealias MessageCompletionObject <T: Object> = (T?) -> Void
public typealias MessageCompletionObjectsList <T: Object> = ([T]) -> Void

protocol SocketConnectionHandler {
    func socketDidConnect(socket: SocketManager)
    func socketDidDisconnect(socket: SocketManager)
    func socketDidReturnError(socket: SocketManager, error: SocketError)
}

class SocketManager {

    static let sharedInstance = SocketManager()

    var serverURL: URL?

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var events: [String: [MessageCompletion]] = [:]

    var isUserAuthenticated = false

    internal var internalConnectionHandler: SocketCompletion?
    internal var connectionHandlers: [String: SocketConnectionHandler] = [:]

    // MARK: Connection

    static func connect(_ url: URL, completion: @escaping SocketCompletion) {
        sharedInstance.serverURL = url
        sharedInstance.internalConnectionHandler = completion

        var request = URLRequest(url: url)
        request.setValue(url.host ?? "", forHTTPHeaderField: "Host")

        sharedInstance.socket = WebSocket(request: request)
        sharedInstance.socket?.advancedDelegate = sharedInstance
        sharedInstance.socket?.pongDelegate = sharedInstance
        sharedInstance.socket?.connect()
    }

    static func disconnect(_ completion: @escaping SocketCompletion) {
        if !(sharedInstance.socket?.isConnected ?? false) {
            completion(sharedInstance.socket, true)
            return
        }

        sharedInstance.isUserAuthenticated = false
        sharedInstance.events = [:]
        sharedInstance.queue = [:]
        sharedInstance.internalConnectionHandler = completion
        sharedInstance.socket?.disconnect()
    }

    // MARK: Messages

    static func send(_ object: [String: Any], completion: MessageCompletion? = nil) {
        var json = JSON(object)

        let identifier: String
        if let jsonId = json["id"].string {
            identifier = jsonId
        } else {
            identifier = String.random(50)
            json["id"] = JSON(identifier)
        }

        if let raw = json.rawString() {
            Log.debug("[WebSocket] \(sharedInstance.socket?.currentURL.description ?? "nil")\n -  will send message: \(raw)")

            sharedInstance.socket?.write(string: raw)

            if completion != nil {
                sharedInstance.queue[identifier] = completion
            }
        } else {
            Log.debug("JSON invalid: \(json)")
        }
    }

    static func subscribe(_ object: [String: Any], eventName: String, completion: @escaping MessageCompletion) {
        guard SocketManager.isConnected() else {
            Log.debug("Error: tried to subscribe to event '\(eventName)' while not connected to socket.")
            return
        }

        if var list = sharedInstance.events[eventName] {
            list.append(completion)
            sharedInstance.events[eventName] = list
        } else {
            send(object, completion: completion)
            sharedInstance.events[eventName] = [completion]
        }
    }

    static func unsubscribe(eventName: String, completion: MessageCompletion? = nil) {
        let request = [
            "msg": "unsub",
            "id": eventName
        ] as [String: Any]

        send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            sharedInstance.events.removeValue(forKey: eventName)
            completion?(response)
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

            API.current()?.client(InfoClient.self).fetchInfo()

            SubscriptionManager.updateSubscriptions(auth, completion: { _ in
                AuthSettingsManager.updatePublicSettings(auth, completion: { _ in

                })

                UserManager.userDataChanges()
                UserManager.changes()
                SubscriptionManager.changes(auth)
                SubscriptionManager.subscribeRoomChanges()
                PermissionManager.changes()
                PermissionManager.updatePermissions()
                CustomEmojiManager.sync()

                API.current()?.client(CommandsClient.self).fetchCommands()

                if let userIdentifier = auth.userId {
                    PushManager.updateUser(userIdentifier)
                }
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
        sharedInstance.connectionHandlers.removeValue(forKey: token)
    }

}

// MARK: WebSocketDelegate

extension SocketManager: WebSocketAdvancedDelegate {

    func websocketDidConnect(socket: WebSocket) {
        Log.debug("[WebSocket] \(socket.currentURL)\n -  did connect")

        let object = [
            "msg": "connect",
            "version": "1",
            "support": ["1", "pre2", "pre1"]
        ] as [String: Any]

        SocketManager.send(object)
    }

    func websocketDidDisconnect(socket: WebSocket, error: Error?) {
        Log.debug("[WebSocket] \(socket.currentURL)\n - did disconnect with error (\(String(describing: error)))")

        isUserAuthenticated = false
        events = [:]
        queue = [:]

        if let handler = internalConnectionHandler {
            internalConnectionHandler = nil
            handler(socket, socket.isConnected)
        }

        for (_, handler) in connectionHandlers {
            handler.socketDidDisconnect(socket: self)
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: Data, response: WebSocket.WSResponse) {
        Log.debug("[WebSocket] did receive data (\(data))")
    }

    static let jsonParseQueue = DispatchQueue(label: "chat.rocket.json.parse", qos: .background)

    func websocketDidReceiveMessage(socket: WebSocket, text: String, response: WebSocket.WSResponse) {
        SocketManager.jsonParseQueue.async {
            let json = JSON(parseJSON: text)

            // JSON is invalid
            guard json.exists() else {
                Log.debug("[WebSocket] \(socket.currentURL)\n - did receive invalid JSON object:\n\(text)")
                return
            }

            if let raw = json.rawString() {
                Log.debug("[WebSocket] \(socket.currentURL)\n - did receive JSON message:\n\(raw)")
            }

            DispatchQueue.main.async {
                self.handleMessage(json, socket: socket)
            }
        }
    }

    func websocketHttpUpgrade(socket: WebSocket, request: String) {
        Log.debug("[WebSocket] http upgrade request (\(request))")
    }

    func websocketHttpUpgrade(socket: WebSocket, response: String) {
        Log.debug("[WebSocket] http upgrade response (\(response))")
    }
}

// MARK: WebSocketPongDelegate

extension SocketManager: WebSocketPongDelegate {

    func websocketDidReceivePong(socket: WebSocketClient, data: Data?) {
        Log.debug("[WebSocket] did receive pong")
    }

}
