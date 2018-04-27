//
//  PublicSettingsRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 02/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class PublicSettingsRequest: APIRequest {
    typealias APIResourceType = PublicSettingsResource

    let requiredVersion = Version(0, 62, 2)
    let path = "/api/v1/settings.public"
    let query: String? =
    """
    fields={
        "type":1
    }&query={
        "_id":{
            "$in":[
                "Site_Url",
                "CDN_PREFIX",
                "Site_Name",
                "Assets_favicon_512",
                "UI_Use_Real_Name",
                "UI_Allow_room_names_with_special_chars",
                "Favorite_Rooms",
                "Accounts_OAuth_Google",
                "Accounts_OAuth_Facebook",
                "Accounts_OAuth_Github",
                "Accounts_OAuth_Gitlab",
                "Accounts_OAuth_Linkedin",
                "Accounts_OAuth_Wordpress",
                "LDAP_Enable",
                "CAS_enabled",
                "CAS_login_url",
                "API_Gitlab_URL",
                "Accounts_ShowFormLogin",
                "Accounts_RegistrationForm",
                "Accounts_PasswordReset",
                "Accounts_EmailOrUsernamePlaceholder",
                "Accounts_PasswordPlaceholder",
                "Accounts_EmailVerification",
                "Accounts_AllowUserProfileChange",
                "Accounts_AllowUserAvatarChange",
                "Accounts_AllowRealNameChange",
                "Accounts_AllowUsernameChange",
                "Accounts_AllowEmailChange",
                "Accounts_AllowPasswordChange",
                "FileUpload_Storage_Type",
                "Message_HideType_uj",
                "Message_HideType_ul",
                "Message_HideType_au",
                "Message_HideType_mute_unmute",
                "Message_HideType_ru",
                "Message_ShowDeletedStatus",
                "Message_AllowDeleting",
                "Message_AllowDeleting_BlockDeleteInMinutes",
                "Message_ShowEditedStatus",
                "Message_AllowEditing",
                "Message_AllowEditing_BlockEditInMinutes",
                "Message_AllowPinning",
                "Message_AllowStarring",
                "Message_GroupingPeriod",
                "Message_MaxAllowedSize",
                "Accounts_CustomFields",
                "First_Channel_After_Login"
            ]
        }
    }
    """.removingWhitespaces()
}

final class PublicSettingsResource: APIResource {
    var authSettings: AuthSettings {
        let authSettings = AuthSettings()

        if let authSettingsRaw = raw?["settings"] {
            authSettings.map(authSettingsRaw, realm: nil)
        }

        return authSettings
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }

    var errorMessage: String? {
        return raw?["error"].string
    }
}
