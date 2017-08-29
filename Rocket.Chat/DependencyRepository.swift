//
//  DependencyRepository.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class DependencyRepository {
    static var socketManager: SocketManager = AppSocketManager()
    static var authManager: AuthManager = AppAuthManager()
    static var authSettingsManager = AuthSettingsManager()
    static var subscriptionManager = SubscriptionManager()
    static var userManager = UserManager()
    static var messageManager = MessageManager()
    static var uploadManager = UploadManager()
    static var pushManager = PushManager()
    static var serverManager = ServerManager()
    static var messageTextCacheManager = MessageTextCacheManager()
    static var downloadManager = DownloadManager()
}
