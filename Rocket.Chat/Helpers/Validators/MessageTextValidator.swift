//
//  MessageTextValidator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct MessageTextValidator {

    static func isSizeValid(text: String) -> Bool {
        guard let settings = AuthSettingsManager.settings else { return true }

        if settings.messageMaxAllowedSize <= 0 {
            return true
        }

        return text.utf16.count <= settings.messageMaxAllowedSize
    }

}
