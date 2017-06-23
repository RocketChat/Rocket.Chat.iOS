//
//  DependencyRepository.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/31/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

public class DependencyRepository: InjectionContainer {
    public var socketManager: SocketManager = SDKSocketManager()
    public var authManager = AuthManager()
    public var subscriptionManager: SubscriptionManager = LiveChatSubscriptionManager()
    public var userManager = UserManager()
    public var messageManager = MessageManager()
    public var uploadManager = UploadManager()
    public var pushManager = PushManager()
    public var messageTextCacheManager = MessageTextCacheManager()

    public var livechatManager = LiveChatManager()

    init() {
        socketManager.injectionContainer = self
        authManager.injectionContainer = self
        subscriptionManager.injectionContainer = self
        userManager.injectionContainer = self
        messageManager.injectionContainer = self
        pushManager.injectionContainer = self

        livechatManager.injectionContainer = self
    }
}
