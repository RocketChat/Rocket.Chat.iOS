//
//  UploadRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

final class UploadMessageRequest: APIRequest {
    typealias APIResourceType = UploadMessageResource

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
        let tempFileUrl = URL(fileURLWithPath: "\(NSTemporaryDirectory())upload_\(String.random(10)).temp")

        FileManager.default.createFile(atPath: tempFileUrl.path, contents: nil)

        guard let fileHandle = FileHandle(forWritingAtPath: tempFileUrl.path) else {
            return nil
        }

        // write prefix

        var prefixData = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        prefixData.appendString(boundaryPrefix)
        prefixData.appendString("Content-Disposition: form-data; name=\"msg\"\r\n\r\n")
        prefixData.appendString(msg)

        prefixData.appendString("\r\n".appending(boundaryPrefix))
        prefixData.appendString("Content-Disposition: form-data; name=\"description\"\r\n\r\n")
        prefixData.appendString(description)

        prefixData.appendString("\r\n".appending(boundaryPrefix))
        prefixData.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        prefixData.appendString("Content-Type: \(mimetype)\r\n\r\n")

        //try? prefixData.append(fileURL: tempFileUrl)
        fileHandle.write(prefixData)

        // write file

        fileHandle.seekToEndOfFile()
        fileHandle.write(data)

        // write suffix

        var suffixData = Data()
        suffixData.appendString("\r\n--".appending(boundary.appending("--")))

        fileHandle.seekToEndOfFile()
        fileHandle.write(suffixData)

        fileHandle.closeFile()

        // return mapped data

        return try? Data(contentsOf: tempFileUrl, options: .mappedIfSafe)
    }
}

final class UploadMessageResource: APIResource {
    var error: String? {
        return raw?["error"].string
    }
}
