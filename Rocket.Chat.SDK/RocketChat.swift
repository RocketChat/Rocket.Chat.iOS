//
//  RocketChat.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

/// Main interface of the RocketChat SDK
public final class RocketChat {

    /// Dependency injection container, replace it to change the behavior of the SDK
    public static var injectionContainer = DependencyRepository()

    /// Configure the RocketChat SDK, should be called before any other operations with the SDK for SDK initialization.
    ///
    /// - Parameters:
    ///   - serverURL: a `URL` object that refer to the RocketChat server address
    ///   - secured: if the connection should be made under TLS, defaults to true
    ///   - completion: will be called after the initialization
    public class func configure(withServerURL serverURL: URL, secured: Bool = true, completion: @escaping () -> Void) {
        guard let socketURL = serverURL.socketURL(secured: secured) else {
            return
        }
        Launcher().prepareToLaunch(with: nil)
        injectionContainer.socketManager.connect(socketURL) { (_, _) in
            self.injectionContainer.authManager.updatePublicSettings(nil) { _ in
                DispatchQueue.global(qos: .background).async(execute: completion)
            }
        }
    }

    /// Get the default livechat manager
    ///
    /// - Returns: an instance of `LiveChatManager`
    public class func livechat() -> LiveChatManager {
        return injectionContainer.livechatManager
    }

    /// Get the default auth manager
    ///
    /// - Returns: an instance of `AuthManager`
    public class func auth() -> AuthManager {
        return injectionContainer.authManager
    }

    /// Get the default user manager
    ///
    /// - Returns: an instance of `UserManager`
    public class func user() -> UserManager {
        return injectionContainer.userManager
    }

    /// Get the default socket manager
    ///
    /// - Returns: an instance of `SocketManager`
    public class func socket() -> SocketManager {
        return injectionContainer.socketManager
    }

    /// Get the default push manager
    ///
    /// - Returns: an instance of `PushManager`
    public class func push() -> PushManager {
        return injectionContainer.pushManager
    }
}
