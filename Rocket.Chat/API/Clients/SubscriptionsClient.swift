//
//  SubscriptionsClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import RealmSwift

struct SubscriptionsClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func markAsRead(subscription: UnmanagedSubscription) {
        let req = SubscriptionReadRequest(rid: subscription.rid)
        let subscriptionIdentifier = subscription.rid

        Realm.execute({ (realm) in
            if let subscription = Subscription.find(rid: subscriptionIdentifier, realm: realm) {
                subscription.alert = false
                subscription.unread = 0
                subscription.userMentions = 0
                subscription.groupMentions = 0
                realm.add(subscription, update: true)
            }
        })

        api.fetch(req, completion: nil)
    }

    func fetchSubscriptions(updatedSince: Date?, realm: Realm? = Realm.current, completion: (() -> Void)? = nil) {
        let req = SubscriptionsRequest(updatedSince: updatedSince)

        api.fetch(req, options: [.retryOnError(count: 3)]) { response in
            switch response {
            case .resource(let resource):
                guard resource.success == true else {
                    completion?()
                    return
                }

                let subscriptions = List<Subscription>()

                realm?.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }

                    func queueSubscriptionForUpdate(_ object: JSON) {
                        var subscription: Subscription?

                        if let rid = object["rid"].string {
                            subscription = Subscription.find(rid: rid, realm: realm) ??
                                Subscription.getOrCreate(realm: realm, values: object, updates: nil)
                        } else {
                            subscription = Subscription.getOrCreate(realm: realm, values: object, updates: nil)
                        }

                        if let subscription = subscription {
                            subscription.auth = auth
                            subscription.map(object, realm: realm)
                            subscription.mapRoom(object, realm: realm)
                            subscriptions.append(subscription)
                        }
                    }

                    resource.list?.forEach(queueSubscriptionForUpdate)
                    resource.update?.forEach(queueSubscriptionForUpdate)

                    resource.remove?.forEach { object in
                        var subscription: Subscription?

                        if let rid = object["rid"].string {
                            subscription = Subscription.find(rid: rid, realm: realm) ??
                                Subscription.getOrCreate(realm: realm, values: object, updates: nil)
                        } else {
                            subscription = Subscription.getOrCreate(realm: realm, values: object, updates: nil)
                        }

                        if let subscription = subscription {
                            subscription.auth = nil
                            subscriptions.append(subscription)
                        }
                    }

                    auth.lastSubscriptionFetchWithLastMessage = Date.serverDate

                    realm.add(subscriptions, update: true)
                    realm.add(auth, update: true)
                }, completion: completion)
            case .error:
                completion?()
            }
        }
    }

    func fetchRooms(updatedSince: Date?, realm: Realm? = Realm.current, completion: (() -> Void)? = nil) {
        let req = RoomsRequest(updatedSince: updatedSince)

        api.fetch(req, options: [.retryOnError(count: 3)]) { response in
            switch response {
            case .resource(let resource):
                guard resource.success == true else {
                    completion?()
                    return
                }

                realm?.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }
                    auth.lastRoomFetchWithLastMessage = Date.serverDate
                    realm.add(auth, update: true)
                })

                let subscriptions = List<Subscription>()

                realm?.execute({ realm in
                    func queueRoomValuesForUpdate(_ object: JSON) {
                        guard
                            let rid = object["_id"].string,
                            let subscription = Subscription.find(rid: rid, realm: realm)
                        else {
                            return
                        }

                        subscription.mapRoom(object, realm: realm)
                        subscriptions.append(subscription)
                    }

                    resource.list?.forEach(queueRoomValuesForUpdate)
                    resource.update?.forEach(queueRoomValuesForUpdate)
                    realm.add(subscriptions, update: true)
                }, completion: completion)
            case .error:
                completion?()
            }
        }
    }

    func fetchRoles(subscription: Subscription, realm: Realm? = Realm.current, completion: (() -> Void)? = nil) {
        let rid = subscription.rid
        let rolesRequest = RoomRolesRequest(roomName: subscription.name, subscriptionType: subscription.type)

        let currentRealm = realm

        api.fetch(rolesRequest) { result in
            switch result {
            case .resource(let resource):
                if let subscription = Subscription.find(rid: rid, realm: currentRealm) {
                    Realm.executeOnMainThread(realm: currentRealm) { _ in
                        let subscriptionCopy = Subscription(value: subscription)

                        subscriptionCopy.usersRoles.removeAll()
                        resource.roomRoles?.forEach { role in
                            subscriptionCopy.usersRoles.append(role)
                        }

                        currentRealm?.add(subscriptionCopy, update: true)
                    }

                    completion?()
                }

            // Fail silently
            case .error(let error):
                print(error)
            }
        }
    }
}

// MARK: Members List

extension SubscriptionsClient {
    func fetchMembersList(
        subscription: Subscription,
        options: APIRequestOptionSet = [],
        realm: Realm? = Realm.current,
        completion: @escaping (
            _ response: APIResponse<RoomMembersResource>,
            _ users: [UnmanagedUser]?
        ) -> Void
    ) {
        let request = RoomMembersRequest(roomId: subscription.rid, type: subscription.type)
        api.fetch(request, options: options) { response in
            switch response {
            case .resource(let resource):
                var users = [UnmanagedUser]()
                realm?.execute({ realm in
                    resource.members?.forEach { member in
                        let user = User.getOrCreate(realm: realm, values: member, updates: nil)
                        realm.add(user, update: true)

                        if let unmanaged = user.unmanaged {
                            users.append(unmanaged)
                        }
                    }
                }, completion: {
                    completion(response, users)
                })
            case .error:
                completion(response, nil)
            }
        }
    }
}

// MARK: Subsctiption actions

extension SubscriptionsClient {
    func favoriteSubscription(subscription: Subscription) {
        SubscriptionManager.toggleFavorite(subscription) { (response) in
            DispatchQueue.main.async {
                if response.isError() {
                    subscription.updateFavorite(!subscription.favorite)
                }
            }
        }

        subscription.updateFavorite(!subscription.favorite)
    }

    func hideSubscription(subscription: Subscription) {
        let hideRequest = SubscriptionHideRequest(rid: subscription.rid, subscriptionType: subscription.type)
        api.fetch(hideRequest, completion: nil)

        Realm.executeOnMainThread { realm in
            realm.delete(subscription)
        }
    }

    func markRead(subscription: Subscription) {
        api.fetch(SubscriptionReadRequest(rid: subscription.rid), completion: nil)
        Realm.executeOnMainThread { _ in
            subscription.alert = false
        }
    }

    func markUnread(subscription: Subscription) {
        api.fetch(SubscriptionUnreadRequest(rid: subscription.rid), completion: nil)
        Realm.executeOnMainThread { _ in
            subscription.alert = true
        }
    }
}

// MARK: History

extension RoomHistoryResource {
    func messages(realm: Realm?) -> [Message]? {
        return raw?["messages"].arrayValue.map {
            let message = Message()
            message.map($0, realm: realm)
            return message
        }
    }
}

extension SubscriptionsClient {
    func loadHistory(
        subscription: Subscription,
        latest: Date?,
        count: Int = 30,
        realm: Realm? = Realm.current,
        completion: @escaping (_ lastMessageDate: Date?) -> Void
    ) {
        let request = RoomHistoryRequest(
            roomType: subscription.type,
            roomId: subscription.rid,
            latest: latest,
            count: count
        )

        var lastMessageDate: Date?

        api.fetch(request) { response in
            switch response {
            case .resource(let resource):
                var requestMessageDetails: [String] = []

                realm?.execute({ realm in
                    let messages = resource.messages(realm: realm) ?? []
                    realm.add(messages, update: true)

                    for message in messages where !message.threadMessageId.isEmpty {
                        if Message.find(withIdentifier: message.threadMessageId) != nil {
                            // Main message exists, we don't need to do anything
                        } else {
                            requestMessageDetails.append(message.threadMessageId)
                        }
                    }

                    lastMessageDate = messages.last?.createdAt
                }, completion: {
                    completion(lastMessageDate)

                    // Check for main message of a thread that doesn't exists on the database yet
                    // and needs to be requested
                    requestMessageDetails.forEach({ (identifier) in
                        API.current()?.fetch(GetMessageRequest(msgId: identifier), completion: { response in
                            switch response {
                            case .resource(let resource):
                                if let message = resource.message {
                                    realm?.execute({ realm in
                                        realm.add(message, update: true)
                                    })
                                }
                            default:
                                break
                            }
                        })
                    })
                })
            case .error:
                completion(lastMessageDate)
            }
        }
    }
}
