//
//  LiveChatManagerInjected.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/2/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol LiveChatManagerInjected: Injected {}
extension LiveChatManagerInjected {
    var livechatManager: LiveChatManager {
        return injectionContainer.livechatManager
    }
}
