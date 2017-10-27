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
    @objc dynamic var isGoogleAuthenticationEnabled = false
    @objc dynamic var isLDAPAuthenticationEnabled = false

    // Registration
    @objc dynamic var rawRegistrationForm: String?
    var registrationForm: RegistrationFormAccess {
        guard let rawValue = rawRegistrationForm,
              let value = RegistrationFormAccess(rawValue: rawValue) else {
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

    var hiddenTypes: Set<MessageType> {
        var hiddenTypes = Set<MessageType>()

        if hideMessageUserJoined { hiddenTypes.insert(.userJoined) }
        if hideMessageUserLeft { hiddenTypes.insert(.userLeft) }
        if hideMessageUserAdded { hiddenTypes.insert(.userAdded) }
        if hideMessageUserRemoved { hiddenTypes.insert(.userRemoved) }
        if hideMessageUserMutedUnmuted {
            hiddenTypes.insert(.userMuted)
            hiddenTypes.insert(.userUnmuted)
        }

        return hiddenTypes
    }

    // Custom fields
    @objc dynamic var rawCustomFields: String?
}
