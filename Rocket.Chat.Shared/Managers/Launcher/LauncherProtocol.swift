//
//  LauncherProtocol.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol LauncherProtocol: Injected {
    init()
    init(_ injectionContainer: InjectionContainer)
    var coordinators: [LauncherCoordinator] { get }
}
extension LauncherProtocol {
    init(_ injectionContainer: InjectionContainer) {
        self.init()
        self.injectionContainer = injectionContainer
    }

    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        coordinators.forEach { $0.prepareToLaunch(with: options) }
    }
}

/// A protocol of instance of specific launching agent
public protocol LauncherCoordinator: Injected {
    init()
    init(_ injectionContainer: InjectionContainer)
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?)
}
extension LauncherCoordinator {
    init(_ injectionContainer: InjectionContainer) {
        self.init()
        self.injectionContainer = injectionContainer
    }
}
