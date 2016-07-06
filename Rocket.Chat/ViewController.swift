//
//  ViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/5/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController, WebSocketDelegate, WebSocketPongDelegate {

    var socket: WebSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket = WebSocket(url: NSURL(string: "wss://demo.rocket.chat/websocket")!)
        socket.delegate = self
        socket.pongDelegate = self
        socket.connect()
        
        print(socket.isConnected)
    }
    
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
        
        socket.writeString("{\"msg\":\"connect\",\"version\":\"1\",\"support\":[\"1\",\"pre2\",\"pre1\"]}")
        
        let string = "{\"msg\":\"method\",\"method\":\"login\",\"params\":[{\"resume\":\"ci1wrn9nYaZtUD50_PliNCxehq8P3_hEtTiaSN3qKX8\"}],\"id\":\"1\"}"
        socket.writeString(string)
        
        socket.writeString("{\"msg\":\"method\",\"method\":\"sendMessage\",\"params\":[{\"_id\":\"k12312312321n3BvG\",\"rid\":\"MHNCPQyQnzdjRPiuRMZiFvWAfF4RF4AD5u\",\"msg\":\"12312312312312\"}],\"id\":\"12\"}")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("websocket is disconnected: \(error?.localizedDescription)")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("got some data: \(data.length)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("got some text: \(text)")
    }
    
    func websocketDidReceivePong(socket: WebSocket) {
        print(socket)
    }

}

