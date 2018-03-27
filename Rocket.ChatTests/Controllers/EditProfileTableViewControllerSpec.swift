//
//  EditProfileTableViewControllerSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 26/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class EditProfileTableViewControllerSpec: XCTestCase {

    var editProfile: EditProfileTableViewController!

    override func setUp() {
        super.setUp()

        let storyboard = Storyboard.preferences.instantiate()
        editProfile = storyboard.instantiateViewController(
            withIdentifier: EditProfileTableViewController.identifier
        ) as? EditProfileTableViewController

        // Force viewDidLoad
        _ = editProfile.view
    }

    func testCanEditProfileOnly() {
        let authSettings = AuthSettings()
        authSettings.isAllowedToEditProfile = true
        authSettings.isAllowedToEditAvatar = false
        authSettings.isAllowedToEditName = false
        authSettings.isAllowedToEditUsername = false
        authSettings.isAllowedToEditEmail = false
        authSettings.isAllowedToEditName = false
        authSettings.isAllowedToEditPassword = false

        AuthSettingsManager.shared.internalSettings = authSettings

        XCTAssertEqual(editProfile.canEditAnyInfo, false, "will show edit state without being able to edit anything.")
        XCTAssertEqual(editProfile.numberOfSections, 1, "will show change password section without being able to update it.")
    }

    func testCanEditAnyInfo() {
        let authSettings = AuthSettings()
        authSettings.isAllowedToEditProfile = true
        authSettings.isAllowedToEditAvatar = true

        AuthSettingsManager.shared.internalSettings = authSettings

        XCTAssertEqual(editProfile.canEditAnyInfo, true, "will not show edit state even though being able to edit avatar.")
    }

    func testNumberOfRows() {
        let authSettings = AuthSettings()
        authSettings.isAllowedToEditProfile = true
        authSettings.isAllowedToEditPassword = true

        AuthSettingsManager.shared.internalSettings = authSettings

        editProfile.isLoading = true
        XCTAssertEqual(editProfile.numberOfSections, 0, "will show sections even though it is in loading state.")

        editProfile.isLoading = false
        XCTAssertEqual(editProfile.numberOfSections, 2, "will not show password section even though it is allowed to edit password.")

        authSettings.isAllowedToEditPassword = false
        XCTAssertEqual(editProfile.numberOfSections, 1, "will show change password section without being able to update it.")
    }

    func testEditingState() {
        let authSettings = AuthSettings()
        authSettings.isAllowedToEditProfile = true
        authSettings.isAllowedToEditAvatar = true
        authSettings.isAllowedToEditName = true
        authSettings.isAllowedToEditUsername = true
        authSettings.isAllowedToEditEmail = true
        authSettings.isAllowedToEditName = true

        AuthSettingsManager.shared.internalSettings = authSettings
        editProfile.enableUserInteraction()

        XCTAssertEqual(editProfile.avatarButton.isEnabled, true, "avatar button is not enabled even though it is allowed to edit avatar.")
        XCTAssertEqual(editProfile.name.isEnabled, true, "name field is not enabled even though it is allowed to edit name.")
        XCTAssertEqual(editProfile.username.isEnabled, true, "username field is not enabled even though it is allowed to edit username.")
        XCTAssertEqual(editProfile.email.isEnabled, true, "email field is not enabled even though it is allowed to edit email.")
    }

}
