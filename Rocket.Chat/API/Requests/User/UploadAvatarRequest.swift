//
//  UploadAvatarRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 03/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UploadAvatarRequest: APIRequest {
    typealias APIResourceType = UploadAvatarResource

    let requiredVersion = Version(0, 60, 0)

    let method: HTTPMethod = .post
    var path = "/api/v1/users.setAvatar"

    let contentType: String

    let data: Data
    let filename: String
    let mimetype: String

    let boundary = "Boundary-\(String.random())"

    init(data: Data, filename: String, mimetype: String) {
        self.data = data
        self.filename = filename
        self.mimetype = mimetype

        self.contentType = "multipart/form-data; boundary=\(boundary)"
    }

    func body() -> Data? {
        var data = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        data.appendString("\r\n".appending(boundaryPrefix))
        data.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n")
        data.appendString("Content-Type: \(mimetype))\r\n\r\n")
        data.append(self.data)
        data.appendString("\r\n--".appending(boundary.appending("--")))

        return data
    }
}

final class UploadAvatarResource: APIResource {
    var success: Bool {
        return raw?["success"].bool ?? false
    }

    var error: String? {
        return raw?["error"].string
    }
}
