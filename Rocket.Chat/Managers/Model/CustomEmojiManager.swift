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
    static func sync(realm: Realm? = Realm.current) {
        CustomEmoji.cachedEmojis = nil

        API.current(realm: realm)?.fetch(CustomEmojiRequest()) { response in
            switch response {
            case .resource(let resource):
                guard resource.success else {
                    return Log.debug(resource.errorMessage)
                }

                realm?.execute({ realm in
                    realm.delete(realm.objects(CustomEmoji.self))

                    let emoji = List<CustomEmoji>()
                    resource.customEmoji.forEach({ customEmoji in
                        let realmCustomEmoji = realm.create(CustomEmoji.self, value: customEmoji, update: true)
                        emoji.append(realmCustomEmoji)
                    })

                    realm.add(emoji, update: true)
                })
            case .error(let error):
                switch error {
                case .version: websocketSync(realm)
                default: break
                }
            }
        }
    }

    private static func websocketSync(_ realm: Realm?) {
        let requestEmojis = [
            "msg": "method",
            "method": "listEmojiCustom",
            "params": []
            ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.send(requestEmojis) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let emojis = List<CustomEmoji>()
            let list = response.result["result"].array

            currentRealm?.execute({ realm in
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
