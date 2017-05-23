//
//  Injected.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol InjectionContainer {
    var socketManager: SocketManager { get }
    var authManager: AuthManager { get }
    var uploadManager: UploadManager { get }
}

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

protocol UploadManagerInjected: Injected {}
extension UploadManagerInjected {
    var uploadManager: UploadManager {
        return injectionContainer.uploadManager
    }
}
