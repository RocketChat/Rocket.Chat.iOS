//
//  Bundle+RocketChat.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 6/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Bundle {
    class var rocketChat: Bundle {
        let bundle = Bundle(for: RocketChat.self)
        guard let path = bundle.path(forResource: "RocketChat", ofType: "bundle") else {
            fatalError("Bundle `RocketChat` not found.")
        }
        guard let rocketChatBundle = Bundle(path: path) else {
            fatalError("Bundle `RocketChat` cannot be initialized.")
        }
        return rocketChatBundle
    }
}
