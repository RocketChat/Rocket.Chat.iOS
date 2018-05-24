//
//  ImageCoordinator.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 24/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import Nuke

struct ImageCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplicationLaunchOptionsKey: Any]?) {
        ImagePipeline.Configuration.isAnimatedImageDataEnabled = true
    }
}
