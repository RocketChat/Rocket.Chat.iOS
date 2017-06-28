//
//  LauncherProtocol.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol LauncherProtocol {
    var coordinators: [LauncherCoordinator] { get }
}

extension LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        coordinators.forEach { $0.prepareToLaunch(with: options) }
    }
}

/// A protocol of instance of specific launching agent
public protocol LauncherCoordinator {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?)
}
