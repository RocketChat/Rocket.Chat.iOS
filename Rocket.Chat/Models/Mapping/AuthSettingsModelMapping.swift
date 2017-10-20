//
//  AuthSettingsModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension AuthSettings: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.siteURL = objectForKey(object: values, key: "Site_Url")?.string
        self.cdnPrefixURL = objectForKey(object: values, key: "CDN_PREFIX")?.string

        self.serverName = objectForKey(object: values, key: "Site_Name")?.string

        if let siteURL = self.siteURL {
            // Try URL or use defaultURL instead
            if let assetURL = objectForKey(object: values, key: "Assets_favicon_512")?["url"].string {
                self.serverFaviconURL = "\(siteURL)/\(assetURL)"
            } else if let assetURL = objectForKey(object: values, key: "Assets_favicon_512")?["defaultUrl"].string {
                self.serverFaviconURL = "\(siteURL)/\(assetURL)"
            }
        }

        self.useUserRealName = objectForKey(object: values, key: "UI_Use_Real_Name")?.bool ?? false
        self.allowSpecialCharsOnRoomNames = objectForKey(object: values, key: "UI_Allow_room_names_with_special_chars")?.bool ?? false
        self.favoriteRooms = objectForKey(object: values, key: "Favorite_Rooms")?.bool ?? true

        // Authentication methods
        self.isUsernameEmailAuthenticationEnabled = objectForKey(object: values, key: "Accounts_ShowFormLogin")?.bool ?? true
        self.isGoogleAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Google")?.bool ?? false
        self.isLDAPAuthenticationEnabled = objectForKey(object: values, key: "LDAP_Enable")?.bool ?? false

        // Upload
        self.uploadStorageType = objectForKey(object: values, key: "FileUpload_Storage_Type")?.string

        // HideType
        self.hideMessageUserJoined = objectForKey(object: values, key: "Message_HideType_uj")?.bool ?? false
        self.hideMessageUserLeft = objectForKey(object: values, key: "Message_HideType_ul")?.bool ?? false
        self.hideMessageUserAdded = objectForKey(object: values, key: "Message_HideType_au")?.bool ?? false
        self.hideMessageUserMutedUnmuted = objectForKey(object: values, key: "Message_HideType_mute_unmute")?.bool ?? false
        self.hideMessageUserRemoved = objectForKey(object: values, key: "Message_HideType_ru")?.bool ?? false

        // Custom Fields
        self.rawCustomFields = objectForKey(object: values, key: "Accounts_CustomFields")?.string?.removingWhitespaces()
    }

    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        let result = object.array?.filter { obj in
            return obj["_id"].string == key
        }.first

        return result?["value"]
    }

    private func getCustomFields(from rawString: String?) -> [CustomField] {
        guard let encodedString = rawString?.data(using: .utf8, allowLossyConversion: false) else {
            return []
        }

        do {
            let customFields = try JSON(data: encodedString)

            return customFields.map { (key, value) -> CustomField in
                let field = CustomField.chooseType(from: value, name: key)
                field.map(value, realm: realm)
                return field
            }
        } catch {
            Log.debug(error.localizedDescription)
            return []
        }
    }

    var customFields: [CustomField] {
        return getCustomFields(from: rawCustomFields)
    }
}
