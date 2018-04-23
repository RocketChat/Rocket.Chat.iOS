//
//  EmojiCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/22/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage

final class EmojiView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var emojiImageView: FLAnimatedImageView! {
        didSet {
            emojiImageView.contentMode = .scaleAspectFit
        }
    }
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
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.bounds
        emojiLabel.frame = self.bounds
        emojiImageView.frame = self.bounds
    }
}
