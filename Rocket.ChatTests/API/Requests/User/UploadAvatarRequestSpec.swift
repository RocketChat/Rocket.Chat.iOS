//
//  UploadAvatarRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 06/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class UploadAvatarRequestSpec: APITestCase {

    func testRequest() {
        let preRequest = UploadAvatarRequest(data: Data(), filename: "avatar.jpg", mimetype: "image/jpeg")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertNotNil(request.httpBody)
        XCTAssertEqual(request.url?.path, "/api/v1/users.setAvatar", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssert(request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data") ?? false, "content type is correct")
    }

}
