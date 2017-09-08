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

        self.useUserRealName = objectForKey(object: values, key: "UI_Use_Real_Name")?.bool ?? false

        self.favoriteRooms = objectForKey(object: values, key: "Favorite_Rooms")?.bool ?? true

        self.isUsernameEmailAuthenticationEnabled = objectForKey(object: values, key: "Accounts_ShowFormLogin")?.bool ?? true
        self.isGoogleAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Google")?.bool ?? false
        self.isLDAPAuthenticationEnabled = objectForKey(object: values, key: "LDAP_Enable")?.bool ?? false

        self.uploadStorageType = objectForKey(object: values, key: "FileUpload_Storage_Type")?.string

        // HideType

        self.hideMessageUserJoined = objectForKey(object: values, key: "Message_HideType_uj")?.bool ?? false
        self.hideMessageUserLeft = objectForKey(object: values, key: "Message_HideType_ul")?.bool ?? false
        self.hideMessageUserAdded = objectForKey(object: values, key: "Message_HideType_au")?.bool ?? false
        self.hideMessageUserMutedUnmuted = objectForKey(object: values, key: "Message_HideType_mute_unmute")?.bool ?? false
        self.hideMessageUserRemoved = objectForKey(object: values, key: "Message_HideType_ru")?.bool ?? false
    }

    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        let result = object.array?.filter { obj in
            return obj["_id"].string == key
        }.first

        return result?["value"]
    }
}
