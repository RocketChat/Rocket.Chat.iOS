//
//  EmojiCollectionViewCell.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 3/24/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage

final class EmojiCollectionViewCell: UICollectionViewCell {
    enum Emoji {
        case custom(URL?)
        case standard(String?)
    }

    var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.lineBreakMode = .byClipping
        emojiLabel.textAlignment = .center
        emojiLabel.baselineAdjustment = .alignCenters
        emojiLabel.font = UIFont.systemFont(ofSize: 32)
        emojiLabel.backgroundColor = UIColor.white
        return emojiLabel
    }()

    var emojiImageView: FLAnimatedImageView = {
        let view = FLAnimatedImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    var emoji: Emoji? {
        didSet {
            guard let emoji = emoji else {
                emojiLabel.isHidden = true
                emojiImageView.isHidden = true
                return
            }

            switch emoji {
            case .custom(let url):
                guard let url = url else { return }
                ImageManager.loadImage(with: url, into: emojiImageView)
                emojiImageView.isHidden = false
            case .standard(let string):
                emojiLabel.text = string
                emojiLabel.isHidden = false
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addSubview(emojiLabel)
        addSubview(emojiImageView)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emoji = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emojiLabel.frame = self.bounds
        emojiImageView.frame = self.bounds
    }
}
