//
//  ManagerDelegatesCoordinator.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class ManagerDelegatesCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey : Any]?) {
        SocketManager.sharedInstance.delegate = SocketHandler()
        AuthManager.delegate = AuthHandler()
    }
}
