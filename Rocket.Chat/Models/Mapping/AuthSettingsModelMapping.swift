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
    //swiftlint:disable function_body_length
    func map(_ values: JSON, realm: Realm?) {
        self.siteURL = objectForKey(object: values, key: "Site_Url")?.string?.removingLastSlashIfNeeded()
        self.cdnPrefixURL = objectForKey(object: values, key: "CDN_PREFIX")?.string?.removingLastSlashIfNeeded()

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
        self.isGoogleAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Google")?.bool ?? false
        self.isFacebookAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Facebook")?.bool ?? false
        self.isGitHubAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Github")?.bool ?? false
        self.isGitLabAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Gitlab")?.bool ?? false
        self.isLinkedInAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Linkedin")?.bool ?? false
        self.isWordPressAuthenticationEnabled = objectForKey(object: values, key: "Accounts_OAuth_Wordpress")?.bool ?? false
        self.isLDAPAuthenticationEnabled = objectForKey(object: values, key: "LDAP_Enable")?.bool ?? false
        self.isCASEnabled = objectForKey(object: values, key: "CAS_enabled")?.bool ?? false
        self.casLoginUrl = objectForKey(object: values, key: "CAS_login_url")?.string
        self.gitlabUrl = objectForKey(object: values, key: "API_Gitlab_URL")?.string

        self.isUsernameEmailAuthenticationEnabled = objectForKey(object: values, key: "Accounts_ShowFormLogin")?.bool ?? true
        self.rawRegistrationForm = objectForKey(object: values, key: "Accounts_RegistrationForm")?.string
        self.isPasswordResetEnabled = objectForKey(object: values, key: "Accounts_PasswordReset")?.bool ?? true

        self.firstChannelAfterLogin = objectForKey(object: values, key: "First_Channel_After_Login")?.string

        // Authentication Placeholder Fields
        self.emailOrUsernameFieldPlaceholder = objectForKey(object: values, key: "Accounts_EmailOrUsernamePlaceholder")?.stringValue ?? ""
        self.passwordFieldPlaceholder = objectForKey(object: values, key: "Accounts_PasswordPlaceholder")?.stringValue ?? ""

        // Accounts
        self.emailVerification = objectForKey(object: values, key: "Accounts_EmailVerification")?.bool ?? false
        self.isAllowedToEditProfile = objectForKey(object: values, key: "Accounts_AllowUserProfileChange")?.bool ?? false
        self.isAllowedToEditAvatar = objectForKey(object: values, key: "Accounts_AllowUserAvatarChange")?.bool ?? false
        self.isAllowedToEditName = objectForKey(object: values, key: "Accounts_AllowRealNameChange")?.bool ?? false
        self.isAllowedToEditUsername = objectForKey(object: values, key: "Accounts_AllowUsernameChange")?.bool ?? false
        self.isAllowedToEditEmail = objectForKey(object: values, key: "Accounts_AllowEmailChange")?.bool ?? false
        self.isAllowedToEditPassword = objectForKey(object: values, key: "Accounts_AllowPasswordChange")?.bool ?? false

        // Upload
        self.uploadStorageType = objectForKey(object: values, key: "FileUpload_Storage_Type")?.string

        // HideType
        self.hideMessageUserJoined = objectForKey(object: values, key: "Message_HideType_uj")?.bool ?? false
        self.hideMessageUserLeft = objectForKey(object: values, key: "Message_HideType_ul")?.bool ?? false
        self.hideMessageUserAdded = objectForKey(object: values, key: "Message_HideType_au")?.bool ?? false
        self.hideMessageUserMutedUnmuted = objectForKey(object: values, key: "Message_HideType_mute_unmute")?.bool ?? false
        self.hideMessageUserRemoved = objectForKey(object: values, key: "Message_HideType_ru")?.bool ?? false

        // Message
        if let period = objectForKey(object: values, key: "Message_GroupingPeriod")?.int {
            self.messageGroupingPeriod = period
        }

        self.messageAllowPinning = objectForKey(object: values, key: "Message_AllowPinning")?.bool ?? true
        self.messageAllowStarring = objectForKey(object: values, key: "Message_AllowStarring")?.bool ?? true

        self.messageShowDeletedStatus = objectForKey(object: values, key: "Message_ShowDeletedStatus")?.bool ?? true
        self.messageAllowDeleting = objectForKey(object: values, key: "Message_AllowDeleting")?.bool ?? true
        self.messageAllowDeletingBlockDeleteInMinutes = objectForKey(object: values, key: "Message_AllowDeleting_BlockDeleteInMinutes")?.int ?? 0

        self.messageShowEditedStatus = objectForKey(object: values, key: "Message_ShowEditedStatus")?.bool ?? true
        self.messageAllowEditing = objectForKey(object: values, key: "Message_AllowEditing")?.bool ?? true
        self.messageAllowEditingBlockEditInMinutes = objectForKey(object: values, key: "Message_AllowEditing_BlockEditInMinutes")?.int ?? 0

        self.messageMaxAllowedSize = objectForKey(object: values, key: "Message_MaxAllowedSize")?.int ?? 0

        self.messageReadReceiptEnabled = objectForKey(object: values, key: "Message_Read_Receipt_Enabled")?.bool ?? false
        self.messageReadReceiptStoreUsers = objectForKey(object: values, key: "Message_Read_Receipt_Store_Users")?.bool ?? false

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
