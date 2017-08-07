//
//  WebSocketMock.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import ObjectiveC
@testable import Starscream

typealias OnTextReceived = (String) -> String
typealias OnDataReceived = (Data) -> String

class WebSocketMock: WebSocket {

    var onTextReceived: OnTextReceived?
    var onDataReceived: OnDataReceived?
    var mockConnected = false

    override var isConnected: Bool {
        return mockConnected
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
    override func write(string: String, completion: (() -> ())? = nil) {
        completion?()
        guard let ret = onTextReceived?(string) else {
            return
        }
        DispatchQueue.global(qos: .background).async {
            self.onText?(ret)
            self.delegate?.websocketDidReceiveMessage(socket: self, text: ret)
        }
    }

    /**
     Write binary data to the websocket. This sends it as a binary frame.

     If you supply a non-nil completion block, I will perform it when the write completes.

     - parameter data:       The data to write.
     - parameter completion: The (optional) completion handler.
     */
    override func write(data: Data, completion: (() -> ())? = nil) {
        completion?()
        guard let ret = onDataReceived?(data) else {
            return
        }
        DispatchQueue.global(qos: .background).async {
            self.onText?(ret)
            self.delegate?.websocketDidReceiveMessage(socket: self, text: ret)
        }
    }

    /**
     Write a ping to the websocket. This sends it as a control frame.
     Yodel a   sound  to the planet.    This sends it as an astroid. http://youtu.be/Eu5ZJELRiJ8?t=42s
     */
    override func write(ping: Data, completion: (() -> ())? = nil) {
        completion?()
        
    }
}
