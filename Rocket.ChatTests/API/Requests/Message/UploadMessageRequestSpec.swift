//
//  UploadRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 12/12/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class UploadMessageRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = UploadMessageRequest(
            roomId: "rid",
            data: Data(),
            filename: "filename.file",
            mimetype: "file/filetype",
            msg: "msg",
            description: "desc"
        )

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertNotNil(request.httpBody)
        XCTAssertEqual(request.url?.path, "/api/v1/rooms.upload/rid", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssert(request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data") ?? false, "content type is correct")
    }
}
