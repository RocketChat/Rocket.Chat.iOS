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
        guard
            let settings = AuthSettingsManager.shared.settings,
            let roomId = subscription?.rid,
            let serverId = settings.serverId,
            let prefix = settings.videoChatPrefix,
            let videoChatServerlUrl = settings.videoChatServerUrl
            else {
                return nil
        }

        let md5 = MD5(string: serverId + roomId)
        let md5Hex = md5.map { String(format: "%02hhx", $0) }.joined()
        return "https://\(videoChatServerlUrl)/\(prefix)\(md5Hex)"
    }
}
