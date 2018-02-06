//
//  UploadRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias UploadResult = APIResult<UploadRequest>

class UploadRequest: APIRequest {
    let requiredVersion = Version(0, 60, 0)

    let method: HTTPMethod = .post
    var path: String {
        return "/api/v1/rooms.upload/\(roomId)"
    }

    let contentType: String

    let roomId: String
    let data: Data
    let filename: String
    let mimetype: String
    let msg: String
    let description: String

    let boundary = "Boundary-\(String.random())"

    init(roomId: String, data: Data, filename: String, mimetype: String, msg: String = "", description: String = "") {
        self.roomId = roomId
        self.data = data
        self.filename = filename
        self.mimetype = mimetype
        self.msg = msg
        self.description = description

        self.contentType = "multipart/form-data; boundary=\(boundary)"
    }

    func body() -> Data? {
        var data = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        data.appendString(boundaryPrefix)
        data.appendString("Content-Disposition: form-data; name=\"msg\"\r\n\r\n")
        data.appendString(msg)

        data.appendString("\r\n".appending(boundaryPrefix))
        data.appendString("Content-Disposition: form-data; name=\"description\"\r\n\r\n")
        data.appendString(description)

        data.appendString("\r\n".appending(boundaryPrefix))
        data.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        data.appendString("Content-Type: \(mimetype))\r\n\r\n")
        data.append(self.data)
        data.appendString("\r\n--".appending(boundary.appending("--")))

        return data
    }
}

extension APIResult where T == UploadRequest {
    var error: String? {
        return raw?["error"].string
    }
}
