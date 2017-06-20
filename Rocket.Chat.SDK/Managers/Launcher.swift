//
//  Launcher.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class Launcher: LauncherProtocol {
    lazy var coordinators: [LauncherCoordinator] = {
        return [
            PersistencyCoordinator(),
            UserCoordinator()
        ]
    }()
}
