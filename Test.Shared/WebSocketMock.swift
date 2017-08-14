//
//  WebSocketMock.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import ObjectiveC
import SwiftyJSON
@testable import Starscream

typealias SendMessage = (JSON) -> Void
typealias OnJSONReceived = (JSON, SendMessage) -> Void

class WebSocketMock: WebSocket {

    var onJSONReceived = [OnJSONReceived]()
    var mockConnected = false

    // MARK: - Mock Middlewares

    func use(_ middlewares: OnJSONReceived...) {
        onJSONReceived.append(contentsOf: middlewares)
    }

    // MARK: - Mocks

    override var isConnected: Bool {
        return mockConnected
    }

    convenience init() {
        self.init(url: URL(string: "http://doesnt.matter")!)
    }

    /**
     Connect to the WebSocket server on a background thread.
     */
    override func connect() {
        DispatchQueue.global(qos: .background).async {
            self.mockConnected = true
            self.onConnect?()
            self.delegate?.websocketDidConnect(socket: self)
        }
    }

    /**
     Disconnect from the server. I send a Close control frame to the server, then expect the server to respond with a Close control frame and close the socket from its end. I notify my delegate once the socket has been closed.

     If you supply a non-nil `forceTimeout`, I wait at most that long (in seconds) for the server to close the socket. After the timeout expires, I close the socket and notify my delegate.

     If you supply a zero (or negative) `forceTimeout`, I immediately close the socket (without sending a Close control frame) and notify my delegate.

     - Parameter forceTimeout: Maximum time to wait for the server to close the socket.
     - Parameter closeCode: The code to send on disconnect. The default is the normal close code for cleanly disconnecting a webSocket.
    */
    override func disconnect(forceTimeout: TimeInterval? = nil, closeCode: UInt16 = CloseCode.normal.rawValue) {
        DispatchQueue.global(qos: .background).async {
            self.mockConnected = false
            self.onDisconnect?(nil)
            self.delegate?.websocketDidDisconnect(socket: self, error: nil)
        }
    }

    /**
     Write a string to the websocket. This sends it as a text frame.

     If you supply a non-nil completion block, I will perform it when the write completes.

     - parameter string:        The string to write.
     - parameter completion: The (optional) completion handler.
     */
    override func write(string: String, completion: (() -> Void)? = nil) {
        let send: SendMessage = { json in
            DispatchQueue.global(qos: .background).async {
                guard let string = json.rawString() else { return }
                self.onText?(string)
                self.delegate?.websocketDidReceiveMessage(socket: self, text: string)
            }
        }

        if let data = string.data(using: .utf8) {
            let json = JSON(data: data)
            if json.exists() {
                DispatchQueue.global(qos: .background).async {
                    self.onJSONReceived.forEach { $0(json, send) }
                }
                completion?()
            }
        }
    }

    /**
     Write binary data to the websocket. This sends it as a binary frame.

     If you supply a non-nil completion block, I will perform it when the write completes.

     - parameter data:       The data to write.
     - parameter completion: The (optional) completion handler.
     */
    override func write(data: Data, completion: (() -> Void)? = nil) {
        let send: SendMessage = { json in
            DispatchQueue.global(qos: .background).async {
                guard let string = json.rawString() else { return }
                self.onText?(string)
                self.delegate?.websocketDidReceiveMessage(socket: self, text: string)
            }
        }

        let json = JSON(data: data)
        if json.exists() {
            DispatchQueue.global(qos: .background).async {
                self.onJSONReceived.forEach { $0(json, send) }
            }
            completion?()
        }
    }

    /**
     Write a ping to the websocket. This sends it as a control frame.
     Yodel a   sound  to the planet.    This sends it as an astroid. http://youtu.be/Eu5ZJELRiJ8?t=42s
     */
    override func write(ping: Data, completion: (() -> Void)? = nil) {
        completion?()
    }
}
