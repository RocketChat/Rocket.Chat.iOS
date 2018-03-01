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
        guard let base64EncodedImageRepresentation = UIImageJPEGRepresentation(avatar, 0.9)?.base64EncodedString() else {
            return nil
        }

        let string = "image=@\(base64EncodedImageRepresentation)"
        let data = string.data(using: .utf8)

        return data
    }

    var contentType: String? {
        return "multipart/form-data"
    }
}

extension APIResult where T == SetAvatarRequest {
    var success: Bool {
        return raw?["success"].boolValue ?? false
    }
}
