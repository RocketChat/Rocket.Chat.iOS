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

/// A protocol that represents a listener of socket connection events
public protocol SocketConnectionHandler {
    /// Will be called once the socket did connect
    ///
    /// - Parameter socket: the socket manager
    func socketDidConnect(socket: SocketManager)
    /// Will be called once the socket did disconnect
    ///
    /// - Parameter socket: the socket manager
    func socketDidDisconnect(socket: SocketManager)
}

/// A manager that manages all web socket connection related actions
public class SocketManager: AuthManagerInjected, PushManagerInjected, SubscriptionManagerInjected, UserManagerInjected {

    var serverURL: URL?

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var events: [String: [MessageCompletion]] = [:]

    var internalConnectionHandler: SocketCompletion?
    var connectionHandlers: [String: SocketConnectionHandler] = [:]

    // MARK: Connection

    func connect(socket: WebSocket, completion: SocketCompletion? = nil) {
        self.serverURL = socket.currentURL
        self.internalConnectionHandler = completion

        self.socket = socket
        self.socket?.delegate = self
        self.socket?.pongDelegate = self
        self.socket?.headers = [
            "Host": self.serverURL?.host ?? ""
        ]

        self.socket?.connect()
    }

    func connect(_ url: URL, completion: SocketCompletion? = nil) {
        self.serverURL = url
        self.internalConnectionHandler = completion

        self.socket = WebSocket(url: url)
        self.socket?.delegate = self
        self.socket?.pongDelegate = self
        self.socket?.headers = [
            "Host": url.host ?? ""
        ]

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

    /// Clear all socket connection handlers
    public func clear() {
        self.internalConnectionHandler = nil
        self.connectionHandlers = [:]
    }

    // MARK: Messages

    /// Send a given message to connected server
    ///
    /// - Parameters:
    ///   - object: message to be sent
    ///   - completion: will be called after response
    public func send(_ object: [String: Any], completion: MessageCompletion? = nil) {
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

    /// Subscribe an event by event name and an initial message
    ///
    /// - Parameters:
    ///   - object: initial message to subscribe
    ///   - eventName: event to be subscribed
    ///   - completion: will be called after every event fires
    public func subscribe(_ object: [String: Any], eventName: String, completion: @escaping MessageCompletion) {
        if var list = self.events[eventName] {
            list.append(completion)
            self.events[eventName] = list
        } else {
            self.send(object, completion: completion)
            self.events[eventName] = [completion]
        }
    }

    /// Dummy method, should be overriden for each specific usage
    ///
    /// - Parameters:
    ///   - response: error response
    ///   - socket: error socket
    public func handleError(of response: SocketResponse, socket: WebSocket) {
        fatalError("Not implemented.")
    }

}

// MARK: Helpers

extension SocketManager {

    /// Reconnect to server, server settings are retrieved from auth settings
    public func reconnect() {
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

    /// Get if the underlying socket is connected
    ///
    /// - Returns: `true` if connected
    public func isConnected() -> Bool {
        return self.socket?.isConnected ?? false
    }

}

// MARK: Connection handlers

extension SocketManager {

    /// Add a socket connection handler to this socket manager
    ///
    /// - Parameters:
    ///   - token: a unique token for this connection handler
    ///   - handler: the connection handler
    public func addConnectionHandler(token: String, handler: SocketConnectionHandler) {
        self.connectionHandlers[token] = handler
    }

    /// Remove a connection handler by given token
    ///
    /// - Parameter token: token of the connection handler to be removed
    public func removeConnectionHandler(token: String) {
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
