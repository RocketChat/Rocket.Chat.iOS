//
//  SocketResponse.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/22/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import Starscream

public struct SocketResponse {
    var socket: WebSocket?
    var result: JSON

    // JSON Data
    var id: String?
    var msg: ResponseMessage?
    var collection: String?
    var event: String?

    // MARK: Initializer

    init?(_ result: JSON, socket: WebSocket?) {
        self.result = result
        self.socket = socket
        self.id = result["id"].string
        self.collection = result["collection"].string

        if let eventName = result["fields"]["eventName"].string {
            self.event = eventName
        }

        if let msg = result["msg"].string {
            self.msg = ResponseMessage(rawValue: msg) ?? ResponseMessage.unknown

            // Sometimes response is an error, but the "msg" isn't.
            if self.msg == ResponseMessage.unknown {
                if self.isError() {
                    self.msg = ResponseMessage.error
                }
            }
        }
    }

    // MARK: Checks

    func isError() -> Bool {
        if msg == .error || result["error"] != JSON.null {
            return true
        }

        return false
    }
}
