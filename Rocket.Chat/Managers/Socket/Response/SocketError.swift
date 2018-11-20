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
        case emailAlreadyExists
        case other(String)

        init(code: String) {
            switch code {
            case "403", "401":
                self = .invalidSession
            default:
                self = .other(code)
            }
        }

        init?(reason: String) {
            switch reason {
            case "Email already exists.":
                self = .emailAlreadyExists
            default:
                return nil
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
    let reason: String
    let error: SocketError.Error
    let message: String
    let type: String
    let isClientSafe: Bool

    init(json: JSON) {
        details = SocketError.Details(json: json["details"])
        reason = json["reason"].stringValue
        error = SocketError.Error(reason: reason) ?? SocketError.Error(code: json["error"].stringValue)
        message = json["message"].stringValue
        type = json["errorType"].stringValue
        isClientSafe = json["isClientSafe"].boolValue
    }
}
