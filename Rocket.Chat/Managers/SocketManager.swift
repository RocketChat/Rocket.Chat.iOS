//
//  SocketManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream


public typealias MessageCompletion = (AnyObject?) -> Void
public typealias SocketCompletion = (WebSocket?, Bool) -> Void


class SocketManager {
    
    static let sharedInstance = SocketManager()

    var socket: WebSocket?
    var queue: [String: MessageCompletion] = [:]
    var connectionHandler: SocketCompletion?
    
    
    // MARK: Connection
    
    static func connect(url: NSURL, completion: SocketCompletion) {
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
    
    static func sendMessage(text: String, completion: MessageCompletion) {
        sharedInstance.socket?.writeString(text)
        sharedInstance.queue[String.random()] = completion
    }
    
}


// MARK: WebSocketDelegate

extension SocketManager: WebSocketDelegate {
    
    func websocketDidConnect(socket: WebSocket) {
        Log.debug("Socket (\(socket)) did connect")

        connectionHandler?(socket, socket.isConnected)
        connectionHandler = nil
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Log.debug("Socket (\(socket)) did disconnect with error (\(error))")
        
        connectionHandler?(socket, socket.isConnected)
        connectionHandler = nil
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        Log.debug("Socket (\(socket)) did receive data (\(data))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        Log.debug("Socket (\(socket)) did receive message (\(text))")
        
        if queue["123"] != nil {
            let completion = queue["123"]! as MessageCompletion
            completion(text)
        }
    }
    
}


// MARK: WebSocketPongDelegate

extension SocketManager: WebSocketPongDelegate {
    
    func websocketDidReceivePong(socket: WebSocket) {
        Log.debug("Socket (\(socket)) did receive pong")
    }
    
}