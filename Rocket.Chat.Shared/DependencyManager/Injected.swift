//
//  Injected.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol Injected {
    var injectionContainer: InjectionContainer! { get set }
}

protocol SocketManagerInjected: Injected {}
extension SocketManagerInjected {
    var socketManager: SocketManager {
        return injectionContainer.socketManager
    }
}

protocol AuthManagerInjected: Injected {}
extension AuthManagerInjected {
    var authManager: AuthManager {
        return injectionContainer.authManager
    }
}

protocol SubscriptionManagerInjected: Injected {}
extension SubscriptionManagerInjected {
    var subscriptionManager: SubscriptionManager {
        return injectionContainer.subscriptionManager
    }
}

protocol UserManagerInjected: Injected {}
extension UserManagerInjected {
    var userManager: UserManager {
        return injectionContainer.userManager
    }
}

protocol MessageManagerInjected: Injected {}
extension MessageManagerInjected {
    var messageManager: MessageManager {
        return injectionContainer.messageManager
    }
}

protocol UploadManagerInjected: Injected {}
extension UploadManagerInjected {
    var uploadManager: UploadManager {
        return injectionContainer.uploadManager
    }
}

protocol PushManagerInjected: Injected {}
extension PushManagerInjected {
    var pushManager: PushManager {
        return injectionContainer.pushManager
    }
}

protocol MessageTextCacheManagerInjected: Injected {}
extension MessageTextCacheManagerInjected {
    var messageTextCacheManager: MessageTextCacheManager {
        return injectionContainer.messageTextCacheManager
    }
}
