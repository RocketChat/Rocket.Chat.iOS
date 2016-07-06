//
//  SocketManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream
import Log


class SocketManager: WebSocketDelegate, WebSocketPongDelegate {
    
    // Singleton
    static let sharedInstance = SocketManager()
    
    var socket: WebSocket?
    
    
    // MARK: Connection
    
    static func connect(url: NSURL) {
        sharedInstance.socket = WebSocket(url: url)
        sharedInstance.socket?.delegate = sharedInstance
        sharedInstance.socket?.pongDelegate = sharedInstance
        
        sharedInstance.socket?.connect()
    }
    
    static func disconnect() {
        sharedInstance.socket?.disconnect()
    }
    
    
    // MARK: WebSocketDelegate
    
    func websocketDidConnect(socket: WebSocket) {
        Logger().debug("Socket (\(socket)) did connect")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        Logger().debug("Socket (\(socket)) did disconnect with error (\(error))")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        Logger().debug("Socket (\(socket)) did receive data (\(data))")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        Logger().debug("Socket (\(socket)) did receive message (\(text))")
    }
    
    
    // MARK: WebSocketPongDelegate
    
    func websocketDidReceivePong(socket: WebSocket) {
        Logger().debug("Socket (\(socket)) did receive pong")
    }
    
}