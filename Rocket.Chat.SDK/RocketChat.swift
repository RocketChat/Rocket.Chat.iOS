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
    static var mainBundle = Bundle(for: RocketChat.self)
    static var resourceBundle: Bundle? {
        guard let path = mainBundle.path(forResource: "RocketChat", ofType: "bundle") else {
            return nil
        }
        return Bundle(path: path)
    }

    public static func configure(withServerURL serverURL: URL, secured: Bool = true, completion: @escaping () -> Void) {
        guard let socketURL = serverURL.socketURL(secured: secured) else {
            return
        }
        injectionContainer.socketManager.connect(socketURL) { (_, _) in
            self.injectionContainer.authManager.updatePublicSettings(nil) { _ in
                DispatchQueue.global(qos: .background).async(execute: completion)
            }
        }
    }

}
