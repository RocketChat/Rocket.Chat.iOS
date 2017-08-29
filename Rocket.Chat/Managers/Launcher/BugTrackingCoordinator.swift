//
//  BugTrackingCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics

class BugTrackingCoordinator: LauncherCoordinator {

    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        launchFabric()
    }

    private func launchFabric() {
        Fabric.with([Crashlytics.self])
    }
}
