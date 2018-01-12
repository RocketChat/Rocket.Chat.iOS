//
//  CustomEmojiManager.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct CustomEmojiManager {
    static func sync() {
        let requestEmojis = [
            "msg": "method",
            "method": "listEmojiCustom",
            "params": []
        ] as [String: Any]

        SocketManager.send(requestEmojis) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let emojis = List<CustomEmoji>()
            let list = response.result["result"].array

            Realm.execute({ realm in
                realm.delete(realm.objects(CustomEmoji.self))

                list?.forEach { object in
                    let emoji = CustomEmoji.getOrCreate(realm: realm, values: object, updates: nil)
                    emojis.append(emoji)
                }

                realm.add(emojis, update: true)
            })
        }
    }
}
