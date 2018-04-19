//
//  AuthSettingsManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 08/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AuthSettingsManagerSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        // Clear all the Auth objects in Realm
        Realm.executeOnMainThread({ realm in
            for obj in realm.objects(Auth.self) {
                realm.delete(obj)
            }

            for obj in realm.objects(AuthSettings.self) {
                realm.delete(obj)
            }
        })
    }

    func testStaticSettingsAndSharedAreTheSame() {
        let settings = AuthSettings()
        settings.cdnPrefixURL = "foo.bar.baz"

        AuthSettingsManager.shared.internalSettings = settings

        XCTAssertEqual(AuthSettingsManager.shared.settings?.cdnPrefixURL, AuthSettingsManager.settings?.cdnPrefixURL, "static and shared instances are the same")
    }

    func testStaticSettingsAndInternalAreTheSame() {
        let settings = AuthSettings()
        settings.cdnPrefixURL = "foo.bar.baz"

        AuthSettingsManager.shared.internalSettings = settings

        XCTAssertEqual(AuthSettingsManager.shared.internalSettings?.cdnPrefixURL, AuthSettingsManager.settings?.cdnPrefixURL, "static and internal instances are the same")
    }

    func testClearSettings() {
        let settings = AuthSettings()
        settings.cdnPrefixURL = "foo.bar.baz"

        AuthSettingsManager.shared.internalSettings = settings
        XCTAssertEqual(AuthSettingsManager.settings?.cdnPrefixURL, "foo.bar.baz", "settings value exists")

        AuthSettingsManager.shared.clearCachedSettings()
        XCTAssertNil(AuthSettingsManager.shared.internalSettings?.cdnPrefixURL, "settings does not exists")
    }

    func testInternalCachedSettingsUpdatedFromAuth() {
        Realm.executeOnMainThread({ realm in
            let settings = AuthSettings()
            settings.cdnPrefixURL = "foo.bar.baz"

            let auth = Auth()
            auth.serverURL = "https://foo.one"
            auth.lastAccess = Date()
            auth.settings = settings

            realm.add(auth)
        })

        AuthSettingsManager.shared.updateCachedSettings()
        XCTAssertEqual(AuthSettingsManager.settings?.cdnPrefixURL, "foo.bar.baz", "settings are update from auth object")
    }

    func testUpdateCachedSettings() {
        Realm.executeOnMainThread({ realm in
            let settings = AuthSettings()
            settings.cdnPrefixURL = "foo.bar.baz"

            let auth = Auth()
            auth.serverURL = "https://foo.two"
            auth.lastAccess = Date()
            auth.settings = settings

            realm.add(auth)
        })

        AuthSettingsManager.shared.updateCachedSettings()
        XCTAssertEqual(AuthSettingsManager.settings?.cdnPrefixURL, "foo.bar.baz", "settings are update from auth object after running update")
    }

}
