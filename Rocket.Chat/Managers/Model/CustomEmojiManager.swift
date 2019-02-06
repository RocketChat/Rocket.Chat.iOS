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
            if case let .resource(resource) = response {
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
            }
        }
    }

}
