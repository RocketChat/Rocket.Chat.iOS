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

    var serverURL: NSURL?

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var events: [String: [MessageCompletion]] = [:]
    var connectionHandler: SocketCompletion?
    
    
    // MARK: Connection
    
    static func connect(url: NSURL, completion: SocketCompletion) {
        sharedInstance.serverURL = url
        sharedInstance.connectionHandler = completion

        sharedInstance.socket = WebSocket(url: url)
        sharedInstance.socket?.delegate = sharedInstance
        sharedInstance.socket?.pongDelegate = sharedInstance
        
        sharedInstance.socket?.connect()
    }
    
    static func disconnect(completion: SocketCompletion) {
        sharedInstance.connectionHandler = completion
        sharedInstance.socket?.disconnect()
    }
    
    
    // MARK: Messages
    
    static func send(object: AnyObject, completion: MessageCompletion? = nil) {
        let identifier = String.random(50)
        var json = JSON(object)
        json["id"] = JSON(identifier)
        
        if let raw = json.rawString() {
            Log.debug("Socket will send message: \(raw)")
            
            sharedInstance.socket?.writeString(raw)
            
            if completion != nil {
                sharedInstance.queue[identifier] = completion
            }
        } else {
            Log.debug("JSON invalid: \(json)")

            // TODO: JSON is invalid
        }
    }
    
    static func subscribe(object: AnyObject, eventName: String, completion: MessageCompletion? = nil) {
        if let completion = completion {
            var list = sharedInstance.events[eventName] != nil ? sharedInstance.events[eventName] : []
            list?.append(completion)
    
            sharedInstance.events[eventName] = list
        }
        
        self.send(object, completion: completion)
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
        ]
        
        SocketManager.send(object)
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.debug("[WebSocket] did disconnect with error (\(error))")
        
        connectionHandler?(socket, socket.isConnected)
        connectionHandler = nil
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        Log.debug("[WebSocket] did receive data (\(data))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON.parse(text)
        
        // JSON is invalid
        guard json != nil && json.isExists() else {
            Log.debug("[WebSocket] did receive invalid JSON object: \(text)")
            return
        }
    
        Log.debug("[WebSocket] did receive JSON message: \(json.rawString()!)")
        
        let result = SocketResponse(json, socket: socket)
        let collection = result?.collection
        let eventName = result?.eventName
        let fields = json["fields"]
        
        // Server is authenticated right now
        if result?.msg == .Connected {
            connectionHandler?(socket, true)
            connectionHandler = nil
            return
        }
        
        // Server sent a ping message, we must respond with pong
        if result?.msg == .Ping {
            SocketManager.send(["msg": "pong"])
            return
        }
        
        // Event?
        if result?.msg == .Changed {
            
        }
        
        if let result = result, identifier = json["id"].string {
            if queue[identifier] != nil {
                let completion = queue[identifier]! as MessageCompletion
                completion(result)
            }
        }
    }
    
}


// MARK: WebSocketPongDelegate

extension SocketManager: WebSocketPongDelegate {
    
    func websocketDidReceivePong(socket: WebSocket) {
        Log.debug("[WebSocket] did receive pong")
    }
    
}