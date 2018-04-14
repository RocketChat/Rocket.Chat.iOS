//
//  UserDefaults+Group.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var group: UserDefaults {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier) else {
            fatalError("Could not initialize UserDefaults with suiteName \(AppGroup.identifier)")
        }

        return defaults
    }
}
