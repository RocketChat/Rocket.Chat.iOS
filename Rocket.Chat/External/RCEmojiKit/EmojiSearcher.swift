//
//  EmojiSearcher.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

public typealias EmojiSearchResult = (emoji: Emoji, suggestion: String)

open class EmojiSearcher {
    public let emojis: [Emoji]

    public init(emojis: [Emoji]) {
        self.emojis = emojis
    }

    public func search(shortname: String, custom: [Emoji] = []) -> [EmojiSearchResult] {
        return (emojis + custom).flatMap { emoji -> EmojiSearchResult? in
            if let suggestion = emoji.shortname.contains(shortname) ? emoji.shortname : emoji.alternates.filter({ $0.contains(shortname) }).first {
                return (emoji: emoji, suggestion: suggestion.contains(":") ? suggestion : ":\(suggestion):")
            }

            return nil
        }.sorted {
            ($0.suggestion.count - shortname.count) < ($1.suggestion.count - shortname.count)
        }
    }
}

public extension EmojiSearcher {
    public static let standard = EmojiSearcher(emojis: Emojione.all)
}
