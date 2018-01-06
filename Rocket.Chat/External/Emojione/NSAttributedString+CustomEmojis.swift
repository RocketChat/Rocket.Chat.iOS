//
//  NSAttributedString+Extensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SDWebImage

extension NSAttributedString {
    func applyingCustomEmojis(_ emojis: [(shortname: String, imageUrl: String)]) -> NSAttributedString {
        return emojis.reduce(self) { attributedString, emoji in
            // replace emojis
            attributedString
        }
    }
}
