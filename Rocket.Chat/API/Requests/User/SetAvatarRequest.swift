//
//  SetAvatarRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 01/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias SetAvatarResult = APIResult<SetAvatarRequest>

class SetAvatarRequest: APIRequest {
    let method: HTTPMethod = .post
    let path = "/api/v1/users.setAvatar"

    let userId: String
    let avatar: UIImage
    let boundary = "Boundary-\(String.random())"

    init(userId: String, avatar: UIImage) {
        self.userId = userId
        self.avatar = avatar
    }

    func body() -> Data? {
        guard let imageData = UIImageJPEGRepresentation(avatar, 0.9) else {
            return nil
        }

        var data = Data()
        let boundaryPrefix = "--\(boundary)\r\n"

        data.appendString(boundaryPrefix)
        data.appendString("\r\n".appending(boundaryPrefix))
        data.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"profile.jpg\"\r\n")
        data.appendString("Content-Type: image/jpeg)\r\n\r\n")
        data.append(imageData)
        data.appendString("\r\n--".appending(boundary.appending("--")))

        return data
    }

    var contentType: String? {
        return "multipart/form-data; boundary=\(boundary)"
    }
}

extension APIResult where T == SetAvatarRequest {
    var success: Bool {
        return raw?["success"].boolValue ?? false
    }
}
