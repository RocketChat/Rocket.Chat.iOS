//
//  Launcher.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class Launcher: LauncherProtocol {

    lazy var coordinators: [LauncherCoordinator] = {
        return [
            PersistencyCoordinator(),
            BugTrackingCoordinator(),
            UserCoordinator(),
            TimestampCoordinator()
        ]
    }()
}
