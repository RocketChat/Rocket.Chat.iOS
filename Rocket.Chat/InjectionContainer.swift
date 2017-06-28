//
//  InjectionContainer.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/2/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

public protocol InjectionContainer {
    var socketManager: SocketManager { get }
    var authManager: AuthManager { get }
    var subscriptionManager: SubscriptionManager { get }
    var userManager: UserManager { get }
    var messageManager: MessageManager { get }
    var uploadManager: UploadManager { get }
    var pushManager: PushManager { get }
    var messageTextCacheManager: MessageTextCacheManager { get }
}
