//
//  LiveChatManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class LiveChatManager: SocketManagerInjected {

    var injectionContainer: InjectionContainer!
    var initiated = false
    var visitorToken = ""

    var isLiveChatEnabled = false
    var title = ""
    var online = false
    var room = String.random()
    var registrationForm = false
    var displayOfflineForm = false

    func initiate(completion: @escaping () -> Void) {
        visitorToken = String.random()
        let params = [
            "msg": "method",
            "method": "livechat:getInitialData",
            "params": [visitorToken]
        ] as [String : Any]
        socketManager.send(params) { response in
            let json = response.result
            self.isLiveChatEnabled = json["enabled"].boolValue
            self.title = json["title"].stringValue
            self.online = json["online"].boolValue
            self.registrationForm = json["registrationForm"].boolValue
            self.displayOfflineForm = json["displayOfflineForm"].boolValue

            if let rid = json["room"].string {
                self.room = rid
            }

            self.initiated = true
            DispatchQueue.global(qos: .background).async(execute: completion)
        }
    }

    func registerGuest(withEmail email: String, name: String, toDepartment department: String, completion: @escaping () -> Void) {
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
                "department": department
            ]]
        ] as [String : Any]
        socketManager.send(params) { response in
            let roomSubscription = Subscription()
            roomSubscription.rid = self.room
            Realm.execute({ realm in
                realm.add(roomSubscription)
            })
            DispatchQueue.global(qos: .background).async(execute: completion)
        }
    }

    func getLiveChatViewController() throws -> ChatViewController? {
        guard self.initiated else {
            fatalError("LiveChatManager methods called before properly initiated.")
        }

        let storyboard = UIStoryboard(name: "Chatting", bundle: nil)
        let chatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        chatViewController?.injectionContainer = injectionContainer
        let realm = try Realm()
        chatViewController?.subscription = Subscription.find(rid: room, realm: realm)
        return chatViewController
    }

    func getAvailableDepartments() {
        guard self.initiated else {
            fatalError("LiveChatManager methods called before properly initiated.")
        }

    }

}
