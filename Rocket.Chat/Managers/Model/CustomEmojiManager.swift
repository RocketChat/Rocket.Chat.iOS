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
                case .version:
                    // For Rocket.Chat < 0.75.0
                    oldSync(realm: realm)
                default:
                    break
                }
            }
        }
    }

    private static func oldSync(realm: Realm? = Realm.current) {
        CustomEmoji.cachedEmojis = nil

        API.current(realm: realm)?.fetch(CustomEmojiRequestOld()) { response in
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
