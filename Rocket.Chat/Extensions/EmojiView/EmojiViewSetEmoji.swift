//
//  EmojiViewSetEmoji.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension EmojiView {
    func setEmoji(_ emoji: Emoji) {
        if case let .custom(imageUrl) = emoji.type, let url = URL(string: imageUrl) {
            ImageManager.loadImage(with: url, into: emojiImageView)
            emojiLabel.text = ""
        } else {
            emojiLabel.text = Emojione.transform(string: emoji.shortname)
            emojiImageView.image = nil
        }
    }
}
