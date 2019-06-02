//
//  MessagesComposerViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

enum Hint {
    case user(User)
    case room(Subscription)
    case command(Command)
    case emoji(Emoji, suggestion: String)
    case userGroup(String)

    var suggestion: String {
        switch self {
        case .user(let user):
            return user.username ?? ""
        case .room(let room):
            return room.name
        case .command(let command):
            return command.command
        case .emoji(let emoji):
            return emoji.suggestion
        case .userGroup(let userGroup):
            return userGroup
        }
    }
}

final class MessagesComposerViewModel {
    var quoteString = ""
    var replyMessageIdentifier = ""
    var messageToEdit: Message?

    let hintPrefixes: [Character] = ["/", "#", "@", ":"]

    var hints: [Hint] = []
    var hintPrefixedWord: String = ""

    var getRecentSenders: (() -> [String])?

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
            hints = User.search(
                usernameContaining: word,
                preference: getRecentSenders?() ?? [],
                includeSelf: false
            ).compactMap {
                if let user = $0.1 as? User {
                    return Hint.user(user)
                } else {
                    return nil
                }
            }

            if "here".contains(word) || word.count == 0 {
                hints.append(.userGroup("here"))
            }

            if "all".contains(word) || word.count == 0 {
                hints.append(.userGroup("all"))
            }
        } else if prefix == "#" {
            let filter = "auth != nil && (privateType == 'c' || privateType == 'p')\(word.isEmpty ? "" : "&& name BEGINSWITH[c] %@")"

            let rooms = realm.objects(Subscription.self).filter(filter, word)

            for room in rooms {
                hints.append(.room(room))
            }

        } else if prefix == "/" {
            let commands: Results<Command>
            if word.count > 0 {
                commands = realm.objects(Command.self).filter("command BEGINSWITH[c] %@", word)
            } else {
                commands = realm.objects(Command.self)
            }

            commands.forEach {
                hints.append(.command($0))
            }
        } else if prefix == ":" {
            let emojis = EmojiSearcher.standard.search(shortname: word.lowercased(), custom: CustomEmoji.emojis())

            emojis.forEach {
                hints.append(.emoji($0.emoji, suggestion: String($0.suggestion.dropFirst())))
            }
        }
    }
}
