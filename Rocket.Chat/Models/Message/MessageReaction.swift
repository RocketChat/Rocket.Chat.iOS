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

final class MessageReaction: BaseModel {
    @objc dynamic var emoji: String?
    var usernames = List<String>()

    func map(emoji: String, json: JSON) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.emoji = emoji

        self.usernames.removeAll()
        json["usernames"].array?.flatMap {
            $0.string
        }.forEach(self.usernames.append)
    }
}
