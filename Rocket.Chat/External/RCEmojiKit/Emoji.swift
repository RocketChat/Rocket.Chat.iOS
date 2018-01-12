//
//  Emoji.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

public enum EmojiType {
    case standard
    case custom(imageUrl: String)
}

public struct Emoji: Codable {
    public let name: String
    public let shortname: String
    public let supportsTones: Bool
    public let alternates: [String]
    public let keywords: [String]

    public let imageUrl: String?

    public var type: EmojiType {
        if let imageUrl = imageUrl {
            return .custom(imageUrl: imageUrl)
        }

        return .standard
    }

    public init(_ name: String, _ shortname: String, _ supportsTones: Bool, _ alternates: [String], _ keywords: [String], _ imageUrl: String? = nil) {
        self.name = name
        self.shortname = shortname
        self.supportsTones = supportsTones
        self.alternates = alternates
        self.keywords = keywords
        self.imageUrl = imageUrl
    }
}
