//
//  Injected.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol SocketManagerInjected {}
extension SocketManagerInjected {
    var socketManager: SocketManager {
        return DependencyRepository.socketManager
    }
}

protocol AuthManagerInjected {}
extension AuthManagerInjected {
    var authManager: AuthManager {
        return DependencyRepository.authManager
    }
}

protocol SubscriptionManagerInjected {}
extension SubscriptionManagerInjected {
    var subscriptionManager: SubscriptionManager {
        return DependencyRepository.subscriptionManager
    }
}

protocol UserManagerInjected {}
extension UserManagerInjected {
    var userManager: UserManager {
        return DependencyRepository.userManager
    }
}

protocol MessageManagerInjected {}
extension MessageManagerInjected {
    var messageManager: MessageManager {
        return DependencyRepository.messageManager
    }
}

protocol UploadManagerInjected {}
extension UploadManagerInjected {
    var uploadManager: UploadManager {
        return DependencyRepository.uploadManager
    }
}

protocol PushManagerInjected {}
extension PushManagerInjected {
    var pushManager: PushManager {
        return DependencyRepository.pushManager
    }
}

protocol ServerManagerInjected {}
extension ServerManagerInjected {
    var serverManager: ServerManager {
        return DependencyRepository.serverManager
    }
}

protocol MessageTextCacheManagerInjected {}
extension MessageTextCacheManagerInjected {
    var messageTextCacheManager: MessageTextCacheManager {
        return DependencyRepository.messageTextCacheManager
    }
}
