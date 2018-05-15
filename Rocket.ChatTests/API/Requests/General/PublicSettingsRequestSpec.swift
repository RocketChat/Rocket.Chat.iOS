//
//  PublicSettingsRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 04/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class PublicSettingsRequestSpec: APISpec {

    func testRequest() {
        let preRequest = PublicSettingsRequest()
        guard let request = preRequest.request(for: api, options: [.paginated(count: 0, offset: 0)]) else {
            return XCTFail("request is not nil")
        }

        //swiftlint:disable line_length
        let path =
            """
            \(api.host.absoluteString)/api/v1/settings.public?fields=%7B%22type%22:1%7D&query=%7B%22_id%22:%7B%22$in%22:%5B%22Site_Url%22,%22CDN_PREFIX%22,%22Site_Name%22,%22Assets_favicon_512%22,%22UI_Use_Real_Name%22,%22UI_Allow_room_names_with_special_chars%22,%22Favorite_Rooms%22,%22Accounts_OAuth_Google%22,%22Accounts_OAuth_Facebook%22,%22Accounts_OAuth_Github%22,%22Accounts_OAuth_Gitlab%22,%22Accounts_OAuth_Linkedin%22,%22Accounts_OAuth_Wordpress%22,%22LDAP_Enable%22,%22CAS_enabled%22,%22CAS_login_url%22,%22API_Gitlab_URL%22,%22Accounts_ShowFormLogin%22,%22Accounts_RegistrationForm%22,%22Accounts_PasswordReset%22,%22Accounts_EmailOrUsernamePlaceholder%22,%22Accounts_PasswordPlaceholder%22,%22Accounts_EmailVerification%22,%22Accounts_AllowUserProfileChange%22,%22Accounts_AllowUserAvatarChange%22,%22Accounts_AllowRealNameChange%22,%22Accounts_AllowUsernameChange%22,%22Accounts_AllowEmailChange%22,%22Accounts_AllowPasswordChange%22,%22FileUpload_Storage_Type%22,%22Message_HideType_uj%22,%22Message_HideType_ul%22,%22Message_HideType_au%22,%22Message_HideType_mute_unmute%22,%22Message_HideType_ru%22,%22Message_ShowDeletedStatus%22,%22Message_AllowDeleting%22,%22Message_AllowDeleting_BlockDeleteInMinutes%22,%22Message_ShowEditedStatus%22,%22Message_AllowEditing%22,%22Message_AllowEditing_BlockEditInMinutes%22,%22Message_AllowPinning%22,%22Message_AllowStarring%22,%22Message_GroupingPeriod%22,%22Message_MaxAllowedSize%22,%22Accounts_CustomFields%22,%22First_Channel_After_Login%22%5D%7D%7D&count=0&offset=0
            """
        let expectedURL = URL(string: path)

        XCTAssertEqual(preRequest.path, "/api/v1/settings.public", "request path is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString =
        """
            {
                "settings": [
                    {
                        "_id": "Accounts_AllowEmailChange",
                        "value": true,
                        "type": "boolean"
                    }
                ],
                "success": true
            }
        """

        let json = JSON(parseJSON: jsonString)

        let result = PublicSettingsResource(raw: json)
        XCTAssertNotNil(result.raw)
        XCTAssertTrue(result.authSettings.isAllowedToEditEmail)
        XCTAssertTrue(result.success)

        let nilResult = PublicSettingsResource(raw: nil)
        XCTAssertNil(nilResult.raw)
    }

}
