//
//  ChatControllerVideoconference.swift
//  RocketChat
//
//  Created by Luís Machado on 18/12/2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension ChatViewController {

    func getVideoconferenceURL() -> String? {
        let settings = AuthManager.isAuthenticated()?.settings ?? AuthSettings()
        guard let roomId = subscription?.rid, let serverId = settings.serverId, let prefix = settings.videoChatPrefix else { return nil }
        let md5 = MD5(string: serverId + roomId)
        let md5Hex = md5.map { String(format: "%02hhx", $0) }.joined()
        return "https://meet.jit.si/\(prefix)\(md5Hex)"
    }
}
