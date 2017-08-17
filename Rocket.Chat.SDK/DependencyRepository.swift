//
//  DependencyRepository.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/31/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

/**
    A simple dependency injection repository
 */
public class DependencyRepository {
    public static var socketManager: SocketManager = SDKSocketManager()
    public static var authManager = AuthManager()
    public static var subscriptionManager: SubscriptionManager = LivechatSubscriptionManager()
    public static var userManager = UserManager()
    public static var messageManager = MessageManager()
    public static var uploadManager = UploadManager()
    public static var pushManager = PushManager()
    public static var serverManager = ServerManager()
    public static var messageTextCacheManager = MessageTextCacheManager()

    public static var livechatManager = LivechatManager()
}
