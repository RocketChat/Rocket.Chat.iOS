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

    let method = "POST"
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

    let boundary = String.random(16)

    init(roomId: String, data: Data, filename: String, mimetype: String, msg: String, description: String) {
        self.roomId = roomId
        self.data = data
        self.filename = filename
        self.mimetype = mimetype
        self.msg = msg
        self.description = description

        self.contentType = "multipart/form-data; boundary=-----------------------\(boundary)"
    }

    func body() -> Data? {
        var data = Data()

        let boundary = "\r\n-----------------------\(self.boundary)\r\n".data(using: .utf8) ?? Data()

        data.append(boundary)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8) ?? Data())
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8) ?? Data())
        data.append(self.data)

        data.append(boundary)
        data.append("Content-Disposition: form-data; name=\"msg\"\r\n\r\n".data(using: .utf8) ?? Data())
        data.append(msg.data(using: .utf8) ?? Data())

        data.append(boundary)
        data.append("Content-Disposition: form-data; name=\"description\"\r\n\r\n".data(using: .utf8) ?? Data())
        data.append(description.data(using: .utf8) ?? Data())

        data.append("\r\n-----------------------\(self.boundary)--\r\n".data(using: .utf8) ?? Data())

        return data
    }
}

extension APIResult where T == SendMessageRequest {

}
