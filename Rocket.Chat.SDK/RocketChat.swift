//
//  RocketChat.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

public final class RocketChat {

    public static var injectionContainer = DependencyRepository()

    public static func configure(withServerURL serverURL: URL, completion: @escaping () -> Void) {
        guard let socketURL = serverURL.socketURL() else {
            return
        }
        injectionContainer.socketManager.connect(socketURL) { (_, connected) in
            self.injectionContainer.authManager.updatePublicSettings(nil) { (settings) in
                DispatchQueue.global(qos: .background).async(execute: completion)
            }
        }
    }

}
