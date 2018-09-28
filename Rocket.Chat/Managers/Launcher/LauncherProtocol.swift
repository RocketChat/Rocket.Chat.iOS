//
//  LauncherProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol LauncherProtocol {
    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?)
}

final class Launcher: LauncherProtocol {
    private lazy var launchers: [LauncherProtocol] = {
        return [
            TestingCoordinator(),
            MigrationCoordinator(),
            PersistencyCoordinator(),
            AnalyticsCoordinator(),
            NetworkCoordinator(),
            TimestampCoordinator(),
            ImageCoordinator()
        ]
    }()

    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        launchers.forEach { $0.prepareToLaunch(with: options) }
    }
}
