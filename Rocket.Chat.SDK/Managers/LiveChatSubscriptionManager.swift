//
//  LiveChatSubscriptionManager.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/30/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class LiveChatSubscriptionManager: SubscriptionManager, LiveChatManagerInjected {
    override func sendTextMessage(_ message: Message, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "sendMessageLivechat",
            "params": [[
                "_id": message.identifier ?? "",
                "rid": message.subscription.rid,
                "msg": message.text,
                "token": livechatManager.visitorToken
                ]]
            ] as [String : Any]

        socketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
}
