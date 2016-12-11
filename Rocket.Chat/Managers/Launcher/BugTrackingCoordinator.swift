//
//  BugTrackingCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Bugsnag
import Fabric
import Crashlytics

struct BugTrackingCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        launchBugsnag()
        launchFabric()
    }

    private func launchBugsnag() {
        guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
              let keys = NSDictionary(contentsOfFile: path) else {
            return
        }

        guard let bugsnag = keys["Bugsnag"] as? String else {
            return
        }

        Bugsnag.start(withApiKey: bugsnag)
    }

    private func launchFabric() {
        Fabric.with([Crashlytics.self])
    }
}
