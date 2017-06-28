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

/// A server's public informations and settings
public class AuthSettings: BaseModel {
    public dynamic var siteURL: String?
    public dynamic var cdnPrefixURL: String?

    // Rooms
    public dynamic var favoriteRooms = true

    // Authentication methods
    public dynamic var isUsernameEmailAuthenticationEnabled = false
    public dynamic var isGoogleAuthenticationEnabled = false
    public dynamic var isLDAPAuthenticationEnabled = false

    // File upload
    public dynamic var uploadStorageType: String?
}
