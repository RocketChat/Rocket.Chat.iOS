//
//  SubscriptionsClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension SubscriptionHistoryResource {
    func messages(realm: Realm?) -> [Message]? {
        return raw?["messages"].arrayValue.map {
            let message = Message()
            message.map($0, realm: realm)
            return message
        }
    }
}

struct SubscriptionsClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func loadHistory(subscription: Subscription, oldest: Date?, count: Int = 60, realm: Realm? = Realm.current, completion: @escaping ([Message]) -> Void) {
        guard let subscriptionId = subscription.identifier else {
            return completion([])
        }

        let request = SubscriptionHistoryRequest(roomType: subscription.type, roomId: subscription.rid, oldest: oldest, count: count)

        var filteredMessages: [Message] = []

        api.fetch(request) { response in
            switch response {
            case .resource(let resource):
                realm?.execute({ (realm) in
                    guard let detachedSubscription = realm.object(ofType: Subscription.self, forPrimaryKey: subscriptionId) else { return }

                    let messages = resource.messages(realm: Realm.current) ?? []

                    messages.forEach { message in
                        if let existingMessage = realm.object(ofType: Message.self, forPrimaryKey: message.identifier) {
                            if existingMessage.updatedAt?.timeIntervalSince1970 == message.updatedAt?.timeIntervalSince1970 {
                                return
                            }
                        }

                        //let message = Message(value: message)
                        message.subscription = detachedSubscription
                        realm.add(message, update: true)

                        if !message.userBlocked {
                            filteredMessages.append(message)
                        }
                    }
                }, completion: {
                    completion(filteredMessages)
                })
            case .error(let error):
                switch error {
                case .version:
                    MessageManager.getHistory(subscription, lastMessageDate: oldest, completion: completion)
                default:
                    completion([])
                }
            }
        }
    }
}
