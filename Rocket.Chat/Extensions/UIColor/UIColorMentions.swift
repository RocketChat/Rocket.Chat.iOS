//
//  UIColorMentions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 14/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension UIColor {
    static func background(for mention: Mention) -> UIColor {
        if mention.username == AuthManager.currentUser()?.username {
            return .primaryAction
        }

        if mention.username == "all" || mention.username == "here" {
            return .attention
        }

        return .white
    }

    static func font(for mention: Mention) -> UIColor {
        if mention.username == AuthManager.currentUser()?.username {
            return .white
        }

        if mention.username == "all" || mention.username == "here" {
            return .white
        }

        return .primaryAction
    }
}
