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
        return "group.ios.chat.rocket"
    }

    static var group: UserDefaults {
        // swiftlint:disable force_unwrapping
        return UserDefaults(suiteName: groupSuiteName)!
    }
}
