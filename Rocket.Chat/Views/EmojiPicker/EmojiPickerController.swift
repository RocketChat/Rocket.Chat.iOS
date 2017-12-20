//
//  EmojiPickerController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class EmojiPickerController: UIViewController {
    var emojiPicker: EmojiPicker! = nil

    override func loadView() {
        super.loadView()

        emojiPicker = EmojiPicker(frame: view.frame)
        view.addSubview(emojiPicker)

        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": emojiPicker]
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": emojiPicker]
            )
        )
    }
}
