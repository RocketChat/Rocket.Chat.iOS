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

    func search(shortname: String, maxResults: Int? = nil) -> [EmojiSearchResult] {
        let results = emojis.flatMap { emoji -> EmojiSearchResult? in
            if let suggestion = emoji.shortname.contains(shortname) ? emoji.shortname : nil {
                return (emoji: emoji, suggestion: suggestion)
            } else if let suggestion = emoji.alternates.filter({ $0.contains(shortname) }).first {
                return (emoji: emoji, suggestion: suggestion)
            }

            return nil
        }

        guard let maxResults = maxResults else { return results }

        let overflow = results.count - maxResults

        guard overflow > 0 else { return results }

        return Array(results.dropLast(overflow))
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
