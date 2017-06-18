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
public typealias MessageCompletionObject <T: Object> = (T) -> Void
public typealias MessageCompletionObjectsList <T: Object> = ([T]) -> Void

protocol SocketConnectionHandler {
    func socketDidConnect(socket: SocketManager)
    func socketDidDisconnect(socket: SocketManager)
}

public class SocketManager: AuthManagerInjected, PushManagerInjected, SubscriptionManagerInjected, UserManagerInjected {

    var injectionContainer: InjectionContainer!

    var serverURL: URL?

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var events: [String: [MessageCompletion]] = [:]

    internal var internalConnectionHandler: SocketCompletion?
    internal var connectionHandlers: [String: SocketConnectionHandler] = [:]

    // MARK: Connection

    func connect(_ url: URL, completion: @escaping SocketCompletion) {
        self.serverURL = url
        self.internalConnectionHandler = completion

        self.socket = WebSocket(url: url)
        self.socket?.delegate = self
        self.socket?.pongDelegate = self

        self.socket?.connect()
    }

    func disconnect(_ completion: @escaping SocketCompletion) {
        if !(self.socket?.isConnected ?? false) {
            completion(self.socket, true)
            return
        }

        self.internalConnectionHandler = completion
        self.socket?.disconnect()
    }

    func clear() {
        self.internalConnectionHandler = nil
        self.connectionHandlers = [:]
    }

    // MARK: Messages

    func send(_ object: [String: Any], completion: MessageCompletion? = nil) {
        let identifier = String.random(50)
        var json = JSON(object)
        json["id"] = JSON(identifier)

        if let raw = json.rawString() {
            Log.debug("Socket will send message: \(raw)")

            self.socket?.write(string: raw)

            if completion != nil {
                self.queue[identifier] = completion
            }
        } else {
            Log.debug("JSON invalid: \(json)")
        }
    }

    func subscribe(_ object: [String: Any], eventName: String, completion: @escaping MessageCompletion) {
        if var list = self.events[eventName] {
            list.append(completion)
            self.events[eventName] = list
        } else {
            self.send(object, completion: completion)
            self.events[eventName] = [completion]
        }
    }

    func handleError(of response: SocketResponse, socket: WebSocket) {
        fatalError("Not implemented.")
    }

}

// MARK: Helpers

extension SocketManager {

    func reconnect() {
        guard let auth = authManager.isAuthenticated() else { return }

        authManager.resume(auth, completion: { (response) in
            guard !response.isError() else {
                return
            }

            self.subscriptionManager.updateSubscriptions(auth, completion: { _ in
                // TODO: Move it to somewhere else
                self.authManager.updatePublicSettings(auth, completion: { _ in

                })

                self.userManager.userDataChanges()
                self.userManager.changes()
                self.subscriptionManager.changes(auth)
                self.pushManager.updateUser()
            })
        })
    }

    func isConnected() -> Bool {
        return self.socket?.isConnected ?? false
    }

}

// MARK: Connection handlers

extension SocketManager {

    func addConnectionHandler(token: String, handler: SocketConnectionHandler) {
        self.connectionHandlers[token] = handler
    }

    func removeConnectionHandler(token: String) {
        self.connectionHandlers[token] = nil
    }

}

// MARK: WebSocketDelegate

extension SocketManager: WebSocketDelegate {

    public func websocketDidConnect(socket: WebSocket) {
        Log.debug("Socket (\(socket)) did connect")

        let object = [
            "msg": "connect",
            "version": "1",
            "support": ["1", "pre2", "pre1"]
        ] as [String : Any]

        self.send(object)
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.debug("[WebSocket] did disconnect with error (\(String(describing: error)))")

        events = [:]
        queue = [:]

        internalConnectionHandler?(socket, socket.isConnected)
        internalConnectionHandler = nil

        for (_, handler) in connectionHandlers {
            handler.socketDidDisconnect(socket: self)
        }
    }

    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        Log.debug("[WebSocket] did receive data (\(data))")
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON(parseJSON: text)

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

    public func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        Log.debug("[WebSocket] did receive pong")
    }

}
