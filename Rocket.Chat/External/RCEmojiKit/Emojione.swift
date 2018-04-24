//
//  Emojione.swift
//
//  Created by Rafael Kellermann Streit (@rafaelks) on 10/10/16.
//  Copyright (c) 2016.
//

import Foundation

struct Emojione {
    static let all: [Emoji] = {
        var emojis = [Emoji]()
        [
            Emojione.people,
            Emojione.nature,
            Emojione.food,
            Emojione.activity,
            Emojione.travel,
            Emojione.objects,
            Emojione.symbols,
            Emojione.flags
        ].forEach { emojis.append(contentsOf: $0) }
        return emojis
    }()

    static let values: [String: String] = {
        guard let file = Bundle.main.url(forResource: "emojiNames", withExtension: "json") else { return [:] }
        guard let contents = try? Data(contentsOf: file, options: []) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: contents)) ?? [:]
    }()

    static func getEmojis(fromFile filename: String) -> [Emoji] {
        guard let file = Bundle.main.url(forResource: filename, withExtension: "json") else { return [] }
        guard let contents = try? Data(contentsOf: file, options: []) else { return [] }
        return (try? JSONDecoder().decode([Emoji].self, from: contents)) ?? []
    }

    static let symbols: [Emoji] = {
        return getEmojis(fromFile: "symbols")
    }()

    static let objects: [Emoji] = {
        return getEmojis(fromFile: "objects")
    }()

    static let nature: [Emoji] = {
        return getEmojis(fromFile: "nature")
    }()

    static let people: [Emoji] = {
        return getEmojis(fromFile: "people")
    }()

    static let food: [Emoji] = {
        return getEmojis(fromFile: "food")
    }()

    static let travel: [Emoji] = {
        return getEmojis(fromFile: "travel")
    }()

    static let activity: [Emoji] = {
        return getEmojis(fromFile: "activity")
    }()

    static let flags: [Emoji] = {
        return getEmojis(fromFile: "flags")
    }()

    static let regional: [Emoji] = {
        return getEmojis(fromFile: "regional")
    }()
}
