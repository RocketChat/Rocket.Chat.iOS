//
//  AuthSettings.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 06/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum RegistrationFormAccess: String {
    case isPublic = "Public"
    case isDisabled = "Disabled"
    case isSecretURL = "Secret URL"
}

final class AuthSettings: BaseModel {
    @objc dynamic var siteURL: String?
    @objc dynamic var cdnPrefixURL: String?

    // Server information
    @objc dynamic var serverName: String?
    @objc dynamic var serverFaviconURL: String?

    // Layout: User Interface
    @objc dynamic var useUserRealName = false
    @objc dynamic var allowSpecialCharsOnRoomNames = false

    // Rooms
    @objc dynamic var favoriteRooms = true

    // Authentication methods
    @objc dynamic var isUsernameEmailAuthenticationEnabled = false
    @objc dynamic var isPasswordResetEnabled = true

    @objc dynamic var isGoogleAuthenticationEnabled = false
    @objc dynamic var isFacebookAuthenticationEnabled = false
    @objc dynamic var isGitHubAuthenticationEnabled = false
    @objc dynamic var isGitLabAuthenticationEnabled = false
    @objc dynamic var isLinkedInAuthenticationEnabled = false
    @objc dynamic var isLDAPAuthenticationEnabled = false

    @objc dynamic var isCASEnabled = false
    @objc dynamic var casLoginUrl: String?

    // Accounts
    @objc dynamic var emailVerification = false

    // Registration
    @objc dynamic var rawRegistrationForm: String?
    var registrationForm: RegistrationFormAccess {
        guard
            let rawValue = rawRegistrationForm,
            let value = RegistrationFormAccess(rawValue: rawValue)
        else {
            return .isPublic
        }
        return value
    }

    // File upload
    @objc dynamic var uploadStorageType: String?

    // Hide Message Types
    @objc dynamic var hideMessageUserJoined: Bool = false
    @objc dynamic var hideMessageUserLeft: Bool = false
    @objc dynamic var hideMessageUserAdded: Bool = false
    @objc dynamic var hideMessageUserMutedUnmuted: Bool = false
    @objc dynamic var hideMessageUserRemoved: Bool = false

    // Message
    @objc dynamic var messageShowDeletedStatus: Bool = true
    @objc dynamic var messageAllowDeleting: Bool = true
    @objc dynamic var messageAllowDeletingBlockDeleteInMinutes: Int = 0

    @objc dynamic var messageShowEditedStatus: Bool = true
    @objc dynamic var messageAllowEditing: Bool = true
    @objc dynamic var messageAllowEditingBlockEditInMinutes: Int = 0

    // Custom fields
    @objc dynamic var rawCustomFields: String?
}
