//
//  AnalyticsCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 11/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import Fabric
import Crashlytics
import Firebase

let kCrashReportingDisabledKey = "kCrashReportingDisabledKey"

private var isFirebaseInitialized = false

struct AnalyticsCoordinator: LauncherProtocol {

    static var isUsageDataLoggingDisabled: Bool {
        return UserDefaults.standard.bool(forKey: kCrashReportingDisabledKey)
    }

    static func toggleCrashReporting(disabled: Bool) {
        UserDefaults.standard.set(disabled, forKey: kCrashReportingDisabledKey)

        if disabled {
            anonymizeCrashReports()
        } else {
            AnalyticsCoordinator().prepareToLaunch(with: nil)
        }
    }

    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        if AnalyticsCoordinator.isUsageDataLoggingDisabled {
            return
        }

        launchFabric()
        launchFirebase()
    }

    private func launchFirebase() {
        #if RELEASE || BETA
        guard
            !isFirebaseInitialized,
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            NSDictionary(contentsOfFile: path) != nil
        else {
            return
        }

        isFirebaseInitialized = true
        FirebaseApp.configure()
        #endif
    }

    private func launchFabric() {
        Fabric.with([Crashlytics.self])

        if let currentUser = AuthManager.currentUser() {
            AnalyticsCoordinator.identifyCrashReports(withUser: currentUser)
        } else {
            AnalyticsCoordinator.anonymizeCrashReports()
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

        if let serverVersion = AuthManager.selectedServerInformation()?[ServerPersistKeys.serverVersion] {
            crashlytics.setObjectValue(serverVersion, forKey: ServerPersistKeys.serverVersion)
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
