//
//  SESubscriptionModelMapping.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 7/23/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import RealmSwift

extension Subscription {
    static func lastMessageText(lastMessage: Message) -> String {
        return ""
    }
}

extension Message {
    func map(_ values: JSON, realm: Realm?) {
    }
}
