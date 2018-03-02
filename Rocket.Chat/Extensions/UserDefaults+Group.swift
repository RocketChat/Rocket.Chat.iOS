//
//  UserDefaults+Group.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var groupSuiteName: String {
        return "group.chat.rocket.ios"
    }

    // swiftlint:disable force_unwrap
    static var group: UserDefaults {
        return UserDefaults(suiteName: groupSuiteName)!
    }
}
