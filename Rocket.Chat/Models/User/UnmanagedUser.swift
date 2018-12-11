import DifferenceKit
//
//  UnmanagedUser.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 8/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct UnmanagedUser: UnmanagedObject, Equatable {
    typealias Object = User

    var identifier: String
    var username: String
    var name: String?
    var privateStatus: String
    var status: UserStatus
    var utcOffset: Double
    var avatarURL: URL?
    var displayName: String

    var managedObject: User? {
        return User.find(withIdentifier: identifier)?.validated()
    }
}

extension UnmanagedUser {
    init?(_ user: User) {
        guard let userUsername = user.username else {
            return nil
        }

        identifier = user.identifier ?? ""
        username = userUsername
        name = user.name
        privateStatus = user.privateStatus
        status = user.status
        utcOffset = user.utcOffset
        avatarURL = user.avatarURL()
        displayName = user.displayName()
    }
}

extension UnmanagedUser: Differentiable {
    typealias DifferenceIdentifier = String

    var differenceIdentifier: String {
        return username
    }
}
