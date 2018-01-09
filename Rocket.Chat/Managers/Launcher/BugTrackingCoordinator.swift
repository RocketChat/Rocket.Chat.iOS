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
import Instabug

struct BugTrackingCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        launchFabric()
        launchInstabug()
    }

    private func launchInstabug() {
        guard
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let keys = NSDictionary(contentsOfFile: path),
            let instabug = keys["Instabug"] as? String
        else {
            return
        }

        Instabug.start(withToken: instabug, invocationEvent: .floatingButton)
    }

    private func launchFabric() {
        Fabric.with([Crashlytics.self])
    }
}
