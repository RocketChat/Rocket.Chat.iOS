//
//  UploadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias UploadProgressBlock = (Int) -> Void
public typealias UploadCompletionBlock = (SocketResponse?, Bool) -> Void

struct FileUpload {
    var name: String
    var size: Int
    var type: String
    var data: Data
}

class UploadManager {

    static let shared = UploadManager()

    fileprivate func requestUpload(_ url: URL, file: FileUpload, formData: JSON?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = String.random()
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())

        for postData in formData?.array ?? [] {
            guard let key = postData["name"].string else { continue }
            guard let value = postData["value"].string else { continue }
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8) ?? Data())
            data.append(value.data(using: .utf8) ?? Data())
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data())
        }

        data.append("Content-Disposition: form-data; name=\"file\"\r\n".data(using: .utf8) ?? Data())
        data.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8) ?? Data())
        data.append(file.data)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        request.httpBody = data
        return request
    }

}
