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

class EmojiCollectionViewCell: UICollectionViewCell {
    enum Emoji {
        case custom(URL?)
        case standard(String?)
    }

    var emojiLabel: UILabel = {
        let lbl = UILabel()
        lbl.lineBreakMode = .byClipping
        lbl.textAlignment = .center
        lbl.baselineAdjustment = .alignCenters
        lbl.font = UIFont.systemFont(ofSize: 32)
        lbl.backgroundColor = UIColor.white
        return lbl
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
                emojiImageView.sd_setImage(with: url, completed: nil)
                emojiImageView.isHidden = false
            case .standard(let string):
                emojiLabel.text = string
                emojiLabel.isHidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
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
