//
//  LauncherProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?)
}

final class Launcher: LauncherProtocol {
    private lazy var launchers: [LauncherProtocol] = {
        return [
            PersistencyCoordinator(),
            BugTrackingCoordinator(),
            UserCoordinator(),
            TimestampCoordinator()
        ]
    }()

    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        launchers.forEach { $0.prepareToLaunch(with: options) }
    }
}
