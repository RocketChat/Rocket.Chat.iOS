//
//  NetworkCoordinator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 12/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct NetworkCoordinator: LauncherProtocol {
    func prepareToLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        NetworkManager.shared.start()
    }
}
