//
//  LiveChatManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

/// A manager that manages all livechat related actions
public class LiveChatManager: SocketManagerInjected, AuthManagerInjected, SubscriptionManagerInjected {

    public var initiated = false
    public var loggedIn = false
    var visitorToken = ""
    var userId = ""
    var token = ""

    public var title = ""
    public var enabled = false
    /// If is there any agents online
    public var online = false
    /// The
    public var room = String.random()
    /// If a form is required for registration
    public var registrationForm = false
    /// If a form should be displayed while no agents are online
    public var displayOfflineForm = false
    public var offlineTitle = "Offline Support"
    public var offlineMessage = ""
    public var offlineUnavailableMessage = ""
    public var offlineSuccessMessage = ""
    /// All available deparments can be talked to
    public var departments: [Department] = []

    /// Initiate livechat settings and retrieve settings from remote server
    ///
    /// - Parameter completion: completion callback
    public func initiate(completion: @escaping () -> Void) {
        visitorToken = String.random()
        let params = [
            "msg": "method",
            "method": "livechat:getInitialData",
            "params": [visitorToken]
        ] as [String : Any]
        socketManager.send(params) { response in
            let json = response.result["result"]
            self.title = json["title"].stringValue
            self.enabled = json["enabled"].boolValue
            self.online = json["online"].boolValue
            self.registrationForm = json["registrationForm"].boolValue
            self.displayOfflineForm = json["displayOfflineForm"].boolValue
            self.offlineTitle = json["offlineTitle"].stringValue
            self.offlineMessage = json["offlineMessage"].stringValue
            self.offlineUnavailableMessage = json["offlineUnavailableMessage"].stringValue
            self.offlineSuccessMessage = json["offlineSuccessMessage"].stringValue

            if let rid = json["room"].string {
                self.room = rid
            }

            self.departments = json["departments"].map { (_, json) in
                return Department(withJSON: json)
            }

            self.initiated = true
            DispatchQueue.main.async(execute: completion)
        }
    }

    /// Register a new guest with given email and name to given department, `LivechatManager` should be initiated first
    ///
    /// - Parameters:
    ///   - email: guest's email
    ///   - name: guest's name
    ///   - department: target department
    ///   - messageText: initial text
    ///   - completion: completion callback
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
                roomSubscription.type = .livechat

                let message = Message()
                message.internalType = ""
                message.createdAt = Date()
                message.text = messageText
                message.identifier = UUID().uuidString
                message.subscription = roomSubscription
                message.temporary = true
                message.user = self.authManager.currentUser()

                let realm = try? Realm()
                try? realm?.write {
                    realm?.add(roomSubscription)
                    realm?.add(message)
                }
                self.subscriptionManager.sendTextMessage(message) { _ in
                    DispatchQueue.main.async(execute: completion)
                }
            }
        }
    }

    /// Login with previous registered user
    ///
    /// - Parameter completion: completion callback
    public func login(completion: @escaping () -> Void) {
        guard self.initiated else {
            fatalError("LiveChatManager methods called before properly initiated.")
        }

        let params = ["resume": token] as [String : Any]
        authManager.auth(params: params) { _ in
            self.loggedIn = true
            DispatchQueue.main.async(execute: completion)
        }
    }

    public func presentSupportViewController() {
        let storyboard = UIStoryboard(name: "Support", bundle: Bundle.rocketChat)
        if online {
            guard let navigationViewController = storyboard.instantiateInitialViewController() as? UINavigationController else {
                fatalError("Unexpected view hierachy: initial view controller is not a navigation controller")
            }
            guard let _ = navigationViewController.viewControllers.first as? SupportViewController else {
                fatalError("Unexpected view hierachy: navigation controller's root view controller is not support view controller")
            }

            navigationViewController.modalPresentationStyle = .formSheet

            DispatchQueue.main.async {
                UIApplication.shared.delegate?.window??.rootViewController?.present(navigationViewController, animated: true, completion: nil)
            }
        } else {
            guard let navigationViewController = storyboard.instantiateViewController(withIdentifier: "offlineSupport") as? UINavigationController else {
                fatalError("Unexpected view hierachy: `offlineSupport` is not a navigation controller")
            }
            guard let _ = navigationViewController.viewControllers.first as? OfflineFormViewController else {
                fatalError("Unexpected view hierachy: navigation controller's root view controller is not offline form view controller")
            }

            navigationViewController.modalPresentationStyle = .formSheet

            DispatchQueue.main.async {
                UIApplication.shared.delegate?.window??.rootViewController?.present(navigationViewController, animated: true, completion: nil)
            }
        }
    }

    /// After user is registrated or logged in, get the actual `ChatViewController` to start conversation
    ///
    /// - Returns: a `ChatViewController` initiated with livechat settings
    public func getLiveChatViewController() -> ChatViewController? {
        guard self.loggedIn else {
            fatalError("LiveChatManager methods called before properly logged in.")
        }
        let storyboard = UIStoryboard(name: "Chatting", bundle: Bundle.rocketChat)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        guard let realm = try? Realm() else { return nil }
        guard let subscription = Subscription.find(rid: room, realm: realm) else { return nil }
        chatViewController?.subscription = subscription
        chatViewController?.leftButton.setImage(nil, for: .normal)
        chatViewController?.messageCellStyle = .bubble
        return chatViewController
    }

    func sendOfflineMessage(email: String, name: String, message: String, completion: @escaping () -> Void) {
        let params = [
            "msg": "method",
            "method": "livechat:sendOfflineMessage",
            "params": [[
                "name": name,
                "email": email,
                "message": message
            ]]
        ] as [String : Any]
        socketManager.send(params) { _ in
            DispatchQueue.main.async {
                completion()
            }
        }

    }

}
