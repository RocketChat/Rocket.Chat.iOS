//
//  EmojiCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/22/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage

class EmojiView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var emojiImageView: FLAnimatedImageView!
    @IBOutlet weak var emojiLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("EmojiView", owner: self, options: nil)

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": contentView]
            )
        )
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": contentView]
            )
        )
    }
}

class EmojiCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var emojiView: EmojiView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.emojiView.emojiLabel.text = ""
        self.emojiView.emojiImageView.image = nil
        self.emojiView.emojiImageView.animatedImage = nil
    }
}
