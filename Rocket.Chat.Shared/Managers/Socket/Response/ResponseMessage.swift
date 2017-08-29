//
//  ResponseMessage.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

/// A enum type indicates types of a socket response message
///
/// - connected: connected
/// - error: error
/// - ping: ping
/// - changed: changed
/// - added: added
/// - updated: updated
/// - removed: removed
/// - unknown: unknown
public enum ResponseMessage: String {
    case connected
    case error
    case ping
    case changed
    case added
    case updated
    case removed
    case unknown
}
