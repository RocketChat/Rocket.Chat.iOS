//
//  LiveChatManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

public class LiveChatManager: SocketManagerInjected, AuthManagerInjected, SubscriptionManagerInjected {

    var injectionContainer: InjectionContainer!
    var initiated = false
    var loggedIn = false
    var visitorToken = ""
    var userId = ""
    var token = ""

    var isLiveChatEnabled = false
    var title = ""
    var online = false
    var room = String.random()
    var registrationForm = false
    var displayOfflineForm = false

    public var departments: [Department] = []

    public func initiate(completion: @escaping () -> Void) {
        visitorToken = String.random()
        let params = [
            "msg": "method",
            "method": "livechat:getInitialData",
            "params": [visitorToken]
        ] as [String : Any]
        socketManager.send(params) { response in
            let json = response.result["result"]
            self.isLiveChatEnabled = json["enabled"].boolValue
            self.title = json["title"].stringValue
            self.online = json["online"].boolValue
            self.registrationForm = json["registrationForm"].boolValue
            self.displayOfflineForm = json["displayOfflineForm"].boolValue

            if let rid = json["room"].string {
                self.room = rid
            }

            self.departments = json["departments"].map { (_, json) in
                return Department(withJSON: json)
            }

            self.initiated = true
            DispatchQueue.global(qos: .background).async(execute: completion)
        }
    }

    public func registerGuestAndLogin(withEmail email: String, name: String, toDepartment department: Department, message messageText: String, completion: @escaping () -> Void) {
        guard self.initiated else {
            fatalError("LiveChatManager methods called before properly initiated.")
        }

        let params = [
            "msg": "method",
            "method": "livechat:registerGuest",
            "params": [[
                "token": visitorToken,
                "name": name,
                "email": email,
                "department": department.id
            ]]
        ] as [String : Any]
        socketManager.send(params) { response in
            let json = response.result["result"]
            self.userId = json["userId"].stringValue
            self.token = json["token"].stringValue

            self.login {
                let roomSubscription = Subscription()
                roomSubscription.identifier = UUID().uuidString
                roomSubscription.rid = self.room
                roomSubscription.name = department.name
                roomSubscription.type = .directMessage

                let message = Message()
                message.internalType = ""
                message.createdAt = Date()
                message.text = messageText
                message.identifier = UUID().uuidString
                message.subscription = roomSubscription
                message.temporary = true
                message.user = self.authManager.currentUser()
                Realm.execute({ realm in
                    realm.add(roomSubscription)
                    realm.add(message)
                })
                self.subscriptionManager.sendTextMessage(message) { _ in
                    DispatchQueue.global(qos: .background).async(execute: completion)
                }
            }
        }
    }

    public func login(completion: @escaping () -> Void) {
        guard self.initiated else {
            fatalError("LiveChatManager methods called before properly initiated.")
        }

        let params = ["resume": token] as [String : Any]
        authManager.auth(params: params) { _ in
            self.loggedIn = true
            DispatchQueue.global(qos: .background).async(execute: completion)
        }
    }

    public func getLiveChatViewController() -> ChatViewController? {
        guard self.loggedIn else {
            fatalError("LiveChatManager methods called before properly logged in.")
        }
        let storyboard = UIStoryboard(name: "Chatting", bundle: RocketChat.resourceBundle)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        chatViewController?.injectionContainer = injectionContainer
        guard let realm = try? Realm() else { return nil }
        guard let subscription = Subscription.find(rid: room, realm: realm) else { return nil }
        chatViewController?.subscription = subscription
        return chatViewController
    }

}
