//
//  Emoji.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum EmojiType {
    case standard
    case custom(imageUrl: String)
}

struct Emoji: Codable {
    let name: String
    let shortname: String
    let supportsTones: Bool
    let alternates: [String]
    let keywords: [String]

    let imageUrl: String?

    var type: EmojiType {
        if let imageUrl = imageUrl {
            return .custom(imageUrl: imageUrl)
        }

        return .standard
    }

    init(_ name: String, _ shortname: String, _ supportsTones: Bool, _ alternates: [String], _ keywords: [String], _ imageUrl: String? = nil) {
        self.name = name
        self.shortname = shortname
        self.supportsTones = supportsTones
        self.alternates = alternates
        self.keywords = keywords
        self.imageUrl = imageUrl
    }
}
