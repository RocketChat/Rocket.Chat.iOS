//
//  UnmanagedUser.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 8/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct UnmanagedUser: UnmanagedObject, Equatable {
    typealias Object = User

    var managedObject: User
    var username: String?
    var name: String?
    var privateStatus: String
    var status: UserStatus
    var utcOffset: Double
}

extension UnmanagedUser {
    init(_ user: User) {
        managedObject = user

        username = user.username
        name = user.name
        privateStatus = user.privateStatus
        status = user.status
        utcOffset = user.utcOffset
    }
}

extension UnmanagedUser: Differentiable {
    typealias DifferenceIdentifier = String

    var differenceIdentifier: String { return username ?? String.random() }
}
