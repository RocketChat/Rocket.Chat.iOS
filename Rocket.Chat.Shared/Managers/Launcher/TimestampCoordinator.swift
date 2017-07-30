//
//  TimestampCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/07/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class TimestampCoordinator: LauncherCoordinator, ServerManagerInjected {

    var injectionContainer: InjectionContainer!
    required init() {}

    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        serverManager.timestampSync()
    }
}
