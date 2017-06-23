//
//  DependencyRepository.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class DependencyRepository: InjectionContainer {
    var socketManager: SocketManager = AppSocketManager()
    var authManager: AuthManager = AppAuthManager()
    var subscriptionManager = SubscriptionManager()
    var userManager = UserManager()
    var messageManager = MessageManager()
    var uploadManager = UploadManager()
    var pushManager = PushManager()
    var messageTextCacheManager = MessageTextCacheManager()

    init() {
        socketManager.injectionContainer = self
        authManager.injectionContainer = self
        subscriptionManager.injectionContainer = self
        userManager.injectionContainer = self
        messageManager.injectionContainer = self
        pushManager.injectionContainer = self
    }
}
