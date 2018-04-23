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

#if BETA || DEBUG
import Instabug
#endif

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

        #if BETA || DEBUG
        Instabug.start(withToken: instabug, invocationEvent: .floatingButton)
        #endif
    }

    private func launchFabric() {
        Fabric.with([Crashlytics.self])

        if let currentUser = AuthManager.currentUser() {
            BugTrackingCoordinator.identifyCrashReports(withUser: currentUser)
        } else {
            BugTrackingCoordinator.anonymizeCrashReports()
        }
    }

    static func identifyCrashReports(withUser user: User) {
        guard let id = user.identifier else {
            return
        }

        let crashlytics = Crashlytics.sharedInstance()
        crashlytics.setUserIdentifier(id)

        if let name = user.name {
            crashlytics.setUserName(name)
        }

        if let email = user.emails.first?.email {
            crashlytics.setUserEmail(email)
        }

        if let serverURL = AuthManager.selectedServerInformation()?[ServerPersistKeys.serverURL] {
            crashlytics.setObjectValue(serverURL, forKey: ServerPersistKeys.serverURL)
        }
    }

    static func anonymizeCrashReports() {
        let crashlytics = Crashlytics.sharedInstance()

        crashlytics.setUserEmail(nil)
        crashlytics.setUserName(nil)
        crashlytics.setUserIdentifier(nil)
        crashlytics.setObjectValue(nil, forKey: ServerPersistKeys.serverURL)
    }
}
