//
//  SocketManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON


public typealias MessageCompletion = (SocketResponse) -> Void
public typealias SocketCompletion = (WebSocket?, Bool) -> Void


class SocketManager {
    
    static let sharedInstance = SocketManager()

    var serverURL: URL?

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var events: [String: [MessageCompletion]] = [:]
    var connectionHandler: SocketCompletion?
    
    
    // MARK: Connection
    
    static func connect(_ url: URL, completion: @escaping SocketCompletion) {
        sharedInstance.serverURL = url
        sharedInstance.connectionHandler = completion

        sharedInstance.socket = WebSocket(url: url)
        sharedInstance.socket?.delegate = sharedInstance
        sharedInstance.socket?.pongDelegate = sharedInstance
        
        sharedInstance.socket?.connect()
    }
    
    static func disconnect(_ completion: @escaping SocketCompletion) {
        sharedInstance.connectionHandler = completion
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

            // TODO: JSON is invalid
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


// MARK: WebSocketDelegate

extension SocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        Log.debug("Socket (\(socket)) did connect")

        // TODO: We must review this info
        let object = [
            "msg": "connect",
            "version": "1",
            "support": ["1", "pre2", "pre1"]
        ] as [String : Any]
        
        SocketManager.send(object)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.debug("[WebSocket] did disconnect with error (\(error))")
        
        connectionHandler?(socket, socket.isConnected)
        connectionHandler = nil
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        Log.debug("[WebSocket] did receive data (\(data))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON.parse(text)
        
        // JSON is invalid
        guard json != nil && json.exists() else {
            Log.debug("[WebSocket] did receive invalid JSON object: \(text)")
            return
        }
    
        Log.debug("[WebSocket] did receive JSON message: \(json.rawString()!)")
        self.handleMessage(json, socket: socket)
    }
    
}


// MARK: WebSocketPongDelegate

extension SocketManager: WebSocketPongDelegate {
    
    func websocketDidReceivePong(socket: WebSocket, data: Data?) {
        Log.debug("[WebSocket] did receive pong")
    }
    
}
