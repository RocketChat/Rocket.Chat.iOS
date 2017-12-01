//
//  UserUpdateRequest.swift
//  Rocket.Chat
//
//  Created by Dennis Post on 25.11.17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/users/update

import SwiftyJSON

typealias UserUpdateResult = APIResult<UserUpdateRequest>

class UserUpdateRequest: APIRequest {
    let method: String = "POST"
    let path = "/api/v1/users.update"
    
    let userId: String
    let user: User
    
    init(userId: String, user: User) {
        self.userId = userId
        self.user = user
    }
    
    func body() -> Data? {
        
        guard let name = user.name, let username = user.username else {
            return nil
        }
        
        let body = JSON([
            "userId": userId,
//            "data.email": user.emails,
            "name": name,
            "username": username
            ])
        
        return body.rawString()?.data(using: .utf8)
    }
    
    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == UserUpdateRequest {
    var user: User? {
        guard let rawMessage = raw?["user"] else { return nil }
        
        let user = User()
        user.map(rawMessage, realm: nil)
        return user
    }
    
    var success: Bool {
        return raw?["success"].boolValue ?? false
    }
}
