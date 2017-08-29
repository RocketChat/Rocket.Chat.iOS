//
//  SDKSocketManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/31/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import Starscream

/// A socket manager that implemented the error handler method
public class SDKSocketManager: SocketManager {
    public override func handleError(of response: SocketResponse, socket: WebSocket) {
        Log.debug("error: " + (response.result["error"].rawString() ?? ""))
    }
}
