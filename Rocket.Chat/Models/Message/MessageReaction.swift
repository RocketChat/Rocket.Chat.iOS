//
//  MessageReaction.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/15/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

final class MessageReaction: Object {
    @objc dynamic var emoji: String?
    var usernames = List<String>()

    func map(emoji: String, json: JSON) {
        self.emoji = emoji

        self.usernames.removeAll()
        json["usernames"].array?.compactMap {
            $0.string
        }.forEach(self.usernames.append)
    }
}
