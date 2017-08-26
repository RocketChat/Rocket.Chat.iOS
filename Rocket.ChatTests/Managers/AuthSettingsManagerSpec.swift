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

    let authSettingsManager = AuthSettingsManager()

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

        authSettingsManager.internalSettings = settings

        XCTAssertEqual(authSettingsManager.settings?.cdnPrefixURL, authSettingsManager.settings?.cdnPrefixURL, "static and shared instances are the same")
    }

    func testStaticSettingsAndInternalAreTheSame() {
        let settings = AuthSettings()
        settings.cdnPrefixURL = "foo.bar.baz"

        authSettingsManager.internalSettings = settings

        XCTAssertEqual(authSettingsManager.internalSettings?.cdnPrefixURL, authSettingsManager.settings?.cdnPrefixURL, "static and internal instances are the same")
    }

    func testClearSettings() {
        let settings = AuthSettings()
        settings.cdnPrefixURL = "foo.bar.baz"

        authSettingsManager.internalSettings = settings
        XCTAssertEqual(authSettingsManager.settings?.cdnPrefixURL, "foo.bar.baz", "settings value exists")

        authSettingsManager.clearCachedSettings()
        XCTAssertNil(authSettingsManager.internalSettings?.cdnPrefixURL, "settings does not exists")
    }

    func testInternalCachedSettingsUpdatedFromAuth() {
        Realm.executeOnMainThread({ realm in
            let settings = AuthSettings()
            settings.identifier = "dumb.settings.01"
            settings.cdnPrefixURL = "foo.bar.baz"

            let auth = Auth()
            auth.serverURL = "https://foo.one"
            auth.lastAccess = Date()
            auth.settings = settings

            realm.add(auth)
        })

        XCTAssertEqual(authSettingsManager.settings?.cdnPrefixURL, "foo.bar.baz", "settings are update from auth object")
    }

    func testUpdateCachedSettings() {
        Realm.executeOnMainThread({ realm in
            let settings = AuthSettings()
            settings.identifier = "dumb.settings.02"
            settings.cdnPrefixURL = "foo.bar.baz"

            let auth = Auth()
            auth.serverURL = "https://foo.two"
            auth.lastAccess = Date()
            auth.settings = settings

            realm.add(auth)
        })

        authSettingsManager.updateCachedSettings()
        XCTAssertEqual(authSettingsManager.settings?.cdnPrefixURL, "foo.bar.baz", "settings are update from auth object after running update")
    }

}
