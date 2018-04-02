//
//  CustomEmojiRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 02/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias CustomEmojiResult = APIResult<CustomEmojiRequest>

class CustomEmojiRequest: APIRequest {
    let path = "/api/v1/emoji-custom"
}

extension APIResult where T == CustomEmojiRequest {
    var customEmoji: [CustomEmoji] {
        var customEmoji: [CustomEmoji] = []
        let customEmojiRaw = raw?["emojis"].array

        customEmojiRaw?.forEach({ customEmojiJSON in
            let emoji = CustomEmoji()
            emoji.map(customEmojiJSON, realm: nil)
            customEmoji.append(emoji)
        })

        return customEmoji
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }
}
