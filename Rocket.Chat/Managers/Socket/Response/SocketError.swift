//
//  SocketError.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

extension SocketError {
    enum Error {
        case invalidSession
        case other(String)

        init(rawValue: String) {
            switch rawValue {
            case "403":
                self = .invalidSession
            default:
                self = .other(rawValue)
            }
        }
    }
}

extension SocketError {
    struct Details {
        let method: String
        init(json: JSON) {
            method = json["method"].stringValue
        }
    }
}

struct SocketError {
    let details: SocketError.Details
    let error: SocketError.Error
    let reason: String
    let message: String
    let type: String
    let isClientSafe: Bool

    init(json: JSON) {
        details = SocketError.Details(json: json["details"])
        error = SocketError.Error(rawValue: json["error"].stringValue)
        reason = json["reason"].stringValue
        message = json["message"].stringValue
        type = json["errorType"].stringValue
        isClientSafe = json["isClientSafe"].boolValue
    }
}
