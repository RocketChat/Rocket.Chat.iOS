//
//  RCEmojiKitLocalizable.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 2/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol RCEmojiKitLocalizable {
    func localized(_ string: String) -> String
}

extension RCEmojiKitLocalizable {
    func localized(_ string: String) -> String {
        return NSLocalizedString(string, tableName: "RCEmojiKit", bundle: Bundle.main, value: "", comment: "")
    }
}
