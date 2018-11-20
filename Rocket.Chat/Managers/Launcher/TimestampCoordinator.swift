//
//  TimestampCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/07/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct TimestampCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        ServerManager.timestampSync()
    }
}
