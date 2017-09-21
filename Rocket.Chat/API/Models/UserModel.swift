//
//  User.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

extension API {
    struct User: Codable {
        let id: String
        let status: String
        let name: String
        let utcOffset: Double
        let username: String

        init?(json: JSON) {
            guard let rawData = try? json.rawData() else { return nil }
            guard let user = try? JSONDecoder().decode(API.User.self, from: rawData) else { return nil }
            self = user
        }
    }
}

extension API.User {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case status = "status"
        case name = "name"
        case utcOffset = "utcOffset"
        case username = "username"
    }
}
