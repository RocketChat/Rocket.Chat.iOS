//
//  Launcher.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class Launcher: LauncherProtocol {

    var injectionContainer: InjectionContainer!

    lazy var coordinators: [LauncherCoordinator] = {
        return [
            PersistencyCoordinator(injectionContainer),
            BugTrackingCoordinator(injectionContainer),
            UserCoordinator(injectionContainer),
            TimestampCoordinator(injectionContainer)
        ]
    }()
}
