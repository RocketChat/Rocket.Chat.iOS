//
//  Subscription.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum SubscriptionType: String {
    case directMessage = "d"
    case channel = "c"
    case group = "p"
}

class Subscription: BaseModel {
    @objc dynamic var auth: Auth?

    @objc internal dynamic var privateType = SubscriptionType.channel.rawValue
    var type: SubscriptionType {
        get { return SubscriptionType(rawValue: privateType) ?? SubscriptionType.group }
        set { privateType = newValue.rawValue }
    }

    @objc dynamic var rid = ""

    // Name of the subscription
    @objc dynamic var name = ""

    // Full name of the user, in the case of
    // using the full user name setting
    // Setting: UI_Use_Real_Name
    @objc dynamic var fname = ""

    @objc dynamic var unread = 0
    @objc dynamic var open = false
    @objc dynamic var alert = false
    @objc dynamic var favorite = false

    @objc dynamic var createdAt: Date?
    @objc dynamic var lastSeen: Date?

    @objc dynamic var roomTopic: String?
    @objc dynamic var roomDescription: String?

    @objc dynamic var otherUserId: String?
    var directMessageUser: User? {
        guard let realm = Realm.shared else { return nil }
        guard let otherUserId = otherUserId else { return nil }
        return realm.objects(User.self).filter("identifier = '\(otherUserId)'").first
    }

    let messages = LinkingObjects(fromType: Message.self, property: "subscription")
}

extension Subscription {

    func displayName() -> String {
        guard let settings = AuthSettingsManager.settings else {
            return name
        }

        if type != .directMessage {
            return settings.allowSpecialCharsOnRoomNames && fname != "" ? fname : name
        }

        return settings.useUserRealName ? fname : name
    }

    func isValid() -> Bool {
        return self.rid.characters.count > 0
    }

    func isJoined() -> Bool {
        return auth != nil || type != .channel
    }

    func fetchRoomIdentifier(_ completion: @escaping MessageCompletionObject <Subscription>) {
        if type == .channel {
            SubscriptionManager.getRoom(byName: name, completion: { [weak self] (response) in
                guard !response.isError() else { return }

                let result = response.result["result"]
                Realm.executeOnMainThread({ realm in
                    if let obj = self {
                        obj.update(result, realm: realm)
                        realm.add(obj, update: true)
                    }
                })

                guard let strongSelf = self else { return }
                completion(strongSelf)
            })
        } else if type == .directMessage {
            SubscriptionManager.createDirectMessage(name, completion: { [weak self] (response) in
                guard !response.isError() else { return }

                let rid = response.result["result"]["rid"].string ?? ""
                Realm.executeOnMainThread({ realm in
                    if let obj = self {
                        obj.rid = rid
                        realm.add(obj, update: true)
                    }
                })

                guard let strongSelf = self else { return }
                completion(strongSelf)
            })
        }
    }

    func fetchMessages(_ limit: Int = 20, lastMessageDate: Date? = nil) -> [Message] {
        var limitedMessages: [Message] = []
        var messages = fetchMessagesQueryResults()

        if let lastMessageDate = lastMessageDate {
            messages = messages.filter("createdAt < %@", lastMessageDate)
        }

        for i in 0..<min(limit, messages.count) {
            limitedMessages.append(messages[i])
        }

        return limitedMessages
    }

    func fetchMessagesQueryResults() -> Results<Message> {
        var filteredMessages = self.messages.filter("userBlocked == false")

        if let hiddenTypes = AuthSettingsManager.settings?.hiddenTypes {
            for hiddenType in hiddenTypes {
                filteredMessages = filteredMessages.filter("internalType != %@", hiddenType.rawValue)
            }
        }

        return filteredMessages.sorted(byKeyPath: "createdAt", ascending: false)
    }

    func updateFavorite(_ favorite: Bool) {
        Realm.executeOnMainThread({ _ in
            self.favorite = favorite
        })
    }

}

extension Subscription {

    static func find(rid: String, realm: Realm) -> Subscription? {
        var object: Subscription?

        if let findObject = realm.objects(Subscription.self).filter("rid == '\(rid)'").first {
            object = findObject
        }

        return object
    }

}
