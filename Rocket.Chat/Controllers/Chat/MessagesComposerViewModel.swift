//
//  MessagesComposerViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class MessagesComposerViewModel {
    let hintPrefixes: [Character] = ["/", "#", "@", ":"]

    var hints: [String] = []
    var hintPrefixedWord: String = ""

    func didChangeHintPrefixedWord(word: String, realm: Realm? = Realm.current) {
        hints = []
        hintPrefixedWord = word

        guard
            let realm = realm,
            let prefix = hintPrefixedWord.first
        else {
            return
        }

        let word = String(word.dropFirst())

        if prefix == "@" {
            hints = User.search(usernameContaining: word, preference: []).map { $0.0 }

            if "here".contains(word) || word.count == 0 {
                hints.append("here")
            }

            if "all".contains(word) || word.count == 0 {
                hints.append("all")
            }
        } else if prefix == "#" {
            let filter = "auth != nil && (privateType == 'c' || privateType == 'p')\(word.isEmpty ? "" : "&& name BEGINSWITH[c] %@")"

            let channels = realm.objects(Subscription.self).filter(filter, word)

            for channel in channels {
                hints.append(channel.name)
            }

        } else if prefix == "/" {
            let commands: Results<Command>
            if word.count > 0 {
                commands = realm.objects(Command.self).filter("command BEGINSWITH[c] %@", word)
            } else {
                commands = realm.objects(Command.self)
            }

            commands.forEach {
                hints.append($0.command)
            }
        } else if prefix == ":" {
            let emojis = EmojiSearcher.standard.search(shortname: word.lowercased(), custom: CustomEmoji.emojis())

            emojis.forEach {
                hints.append($0.suggestion)
            }
        }
    }
}
