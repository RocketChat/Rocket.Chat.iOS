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

    init(userId: String, avatar: UIImage) {
        self.userId = userId
        self.avatar = avatar
    }

    func body() -> Data? {
        guard let imageData = UIImageJPEGRepresentation(avatar, 0.9) else {
            return nil
        }

        let boundary = "avatar"
        var body = Data()

        guard let openingBoundary = "--\(boundary)\r\n".data(using: .utf8),
                let contentInfo = "Content-Disposition: form-data; name=image; filename=imageName.jpg\r\n".data(using: .utf8),
                let contentType = "Content-Type: image/jpeg\r\n\r\n".data(using: .utf8),
                let newLine = "\r\n".data(using: .utf8),
                let closingBoundary = "--\(boundary)--\r\n".data(using: .utf8) else {
            return nil
        }

        body.append(openingBoundary)
        body.append(contentInfo)
        body.append(contentType)
        body.append(imageData)
        body.append(newLine)
        body.append(closingBoundary)

        return body
    }

    var contentType: String? {
        return "multipart/form-data; boundary=avatar"
    }
}

extension APIResult where T == SetAvatarRequest {
    var success: Bool {
        return raw?["success"].boolValue ?? false
    }
}
