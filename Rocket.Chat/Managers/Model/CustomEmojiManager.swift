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
    static func changes() {
        listenUpdates()
        listenDeletes()
    }

    private static func listenUpdates() {
        let eventName = "updateEmojiCustom"
        let request = [
            "msg": "sub",
            "name": "stream-notify-logged",
            "params": [eventName, false]
            ] as [String: Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            print(response)

            /*let object = response.result["fields"]["args"][1]

            Realm.execute({ (realm) in
                let permission = Permission.getOrCreate(realm: realm, values: object, updates: { _ in })
                realm.add(permission, update: true)
            })*/
        }
    }

    private static func listenDeletes() {
        let eventName = "deleteEmojiCustom"
        let request = [
            "msg": "sub",
            "name": "stream-notify-logged",
            "params": [eventName, false]
            ] as [String: Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            print(response)
            /*let object = response.result["fields"]["args"][1]

            Realm.execute({ (realm) in
                let permission = Permission.getOrCreate(realm: realm, values: object, updates: { _ in })
                realm.del
            })*/
        }
    }

    static func sync() {
        let requestEmojis = [
            "msg": "method",
            "method": "listEmojiCustom",
            "params": []
            ] as [String: Any]

        SocketManager.send(requestEmojis) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            print(response)

            let emojis = List<CustomEmoji>()

            // List is used the first time user opens the app
            let list = response.result["result"].array

            // Update & Removed is used on updates
            // let updated = response.result["result"]["update"].array
            // let removed = response.result["result"]["remove"].array

            Realm.execute({ realm in
                realm.delete(realm.objects(CustomEmoji.self))

                list?.forEach { object in
                    let emoji = CustomEmoji.getOrCreate(realm: realm, values: object, updates: nil)
                    emojis.append(emoji)
                }

                /*updated?.forEach { object in
                    let permission = Permission.getOrCreate(realm: realm, values: object, updates: nil)
                    permissions.append(permission)
                }

                removed?.forEach { object in
                    let permission = Permission.getOrCreate(realm: realm, values: object, updates: nil)
                    permissions.append(permission)
                }*/

                realm.add(emojis, update: true)
            })
        }
    }
}

