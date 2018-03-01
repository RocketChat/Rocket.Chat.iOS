//
//  Subscription+User.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Subscription {
    var directMessageUser: User? {
        guard let otherUserId = otherUserId else { return nil }
        return User.find(withIdentifier: otherUserId)
    }

    var roomOwner: User? {
        guard let roomOwnerId = roomOwnerId else { return nil }
        return User.find(withIdentifier: roomOwnerId)
    }
}
