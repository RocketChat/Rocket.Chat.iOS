//
//  CustomEmoji.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class CustomEmoji: BaseModel {
    @objc dynamic var name: String?
    var aliases = List<String>()
    @objc dynamic var ext: String?
}

extension CustomEmoji {
    func imageUrl(serverUrl: String? = AuthManager.isAuthenticated()?.apiHost?.absoluteString) -> String? {
        guard
            let name = name,
            let ext = ext,
            let encodedName = "\(name).\(ext)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let serverUrl = serverUrl
        else {
            return nil
        }

        return "\(serverUrl)/emoji-custom/\(encodedName)"
    }

    static func withShortname(_ shortname: String, realm: Realm? = Realm.shared) -> CustomEmoji? {
        guard let realm = realm, shortname.count > 2 else { return nil }
        let shortname = String(shortname.dropFirst().dropLast())
        return realm.objects(CustomEmoji.self).filter { $0.name == shortname || $0.aliases.contains(shortname) }.first
    }

    static var cachedEmojis: [String: Emoji]?

    static var emojiStrings: [String: Emoji] {
        if let emojis = cachedEmojis {
            return emojis
        }

        let emojisArray = emojis()
        let emojiReplacementStrings = emojisArray.reduce([String: Emoji]()) { dict, emoji -> [String: Emoji] in
            let alternates = emoji.alternates.filter { !$0.isEmpty }
            let emojiStrings = ([emoji.shortname] + alternates).map { (key: $0, value: emoji) }
            return dict.union(dictionary: Dictionary(keyValuePairs: emojiStrings))
        }
        cachedEmojis = emojiReplacementStrings
        return emojiReplacementStrings
    }

    static func emojis() -> [Emoji] {
        guard let emojis = Realm.shared?.objects(CustomEmoji.self) else { return [] }

        return emojis.flatMap { emoji -> Emoji? in
            guard let name = emoji.name, let imageUrl = emoji.imageUrl() else { return nil }
            return Emoji(name, name, false, Array(emoji.aliases), [], imageUrl)
        }
    }
}

extension CustomEmoji: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if identifier == nil {
            identifier = values["_id"].string
        }

        if let aliases = values["aliases"].array?.flatMap({ $0.string }) {
            self.aliases.removeAll()
            self.aliases.append(contentsOf: aliases)
        }

        name = values["name"].stringValue
        ext = values["extension"].stringValue
    }
}
