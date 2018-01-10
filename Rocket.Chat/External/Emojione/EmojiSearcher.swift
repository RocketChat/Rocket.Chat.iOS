//
//  EmojiSearcher.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

typealias EmojiSearchResult = (emoji: Emoji, suggestion: String)

class EmojiSearcher {
    let emojis: [Emoji]

    init(emojis: [Emoji]) {
        self.emojis = emojis
    }

    func search(shortname: String, custom: [Emoji]) -> [EmojiSearchResult] {
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

extension EmojiSearcher {
    static let standard = EmojiSearcher(emojis:
            Emojione.people +
            Emojione.nature +
            Emojione.food +
            Emojione.activity +
            Emojione.travel +
            Emojione.objects +
            Emojione.symbols +
            Emojione.flags
    )
}
