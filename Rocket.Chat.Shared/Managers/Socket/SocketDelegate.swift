//
//  SocketDelegate.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream

public protocol SocketDelegate: class {
    func handleError(of response: SocketResponse, socket: WebSocket)
}
