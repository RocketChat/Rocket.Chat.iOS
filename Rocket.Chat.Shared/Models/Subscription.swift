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
    case livechat = "l"
}

/// A data structure represents a subscription
public class Subscription: BaseModel {
    dynamic var auth: Auth?

    internal dynamic var privateType = SubscriptionType.channel.rawValue
    var type: SubscriptionType {
        get { return SubscriptionType(rawValue: privateType) ?? SubscriptionType.group }
        set { privateType = newValue.rawValue }
    }

    dynamic var rid = ""

    // Name of the subscription
    dynamic var name = ""

    // Full name of the user, in the case of
    // using the full user name setting
    // Setting: UI_Use_Real_Name
    dynamic var fname = ""

    dynamic var unread = 0
    dynamic var open = false
    dynamic var alert = false
    dynamic var favorite = false

    dynamic var createdAt: Date?
    dynamic var lastSeen: Date?

    dynamic var roomTopic: String?
    dynamic var roomDescription: String?

    dynamic var otherUserId: String?
    var directMessageUser: User? {
        guard let otherUserId = otherUserId else { return nil }
        guard let users = try? Realm().objects(User.self).filter("identifier = '\(otherUserId)'") else { return nil }
        return users.first
    }

    let messages = LinkingObjects(fromType: Message.self, property: "subscription")
}

extension Subscription {

    func displayName() -> String {
        if type != .directMessage {
            return name
        }

        guard let settings = DependencyRepository.authSettingsManager.settings else {
            return name
        }

        return settings.useUserRealName ? fname : name
    }

    func isValid() -> Bool {
        return self.rid.characters.count > 0
    }

    func isJoined() -> Bool {
        return auth != nil || type != .channel
    }

    func fetchRoomIdentifier(subscriptionManager: SubscriptionManager, _ completion: @escaping MessageCompletionObject <Subscription>) {
        if type == .channel {
            subscriptionManager.getRoom(byName: name, completion: { [weak self] (response) in
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
            subscriptionManager.createDirectMessage(name, completion: { [weak self] (response) in
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

    func fetchMessages() -> Results<Message> {
        let filter = NSPredicate(format: "userBlocked == false")
        return self.messages.filter(filter).sorted(byKeyPath: "createdAt", ascending: true)
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
