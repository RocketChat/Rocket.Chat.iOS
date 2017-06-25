//
//  Launcher.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

/// Centralized management of launching
public class Launcher: LauncherProtocol {
    /// Actual coodinators
    public lazy var coordinators: [LauncherCoordinator] = {
        return [
            PersistencyCoordinator(),
            UserCoordinator()
        ]
    }()
}
