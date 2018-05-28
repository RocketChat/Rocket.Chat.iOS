//
//  ReactionView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

struct ReactionViewModel {
    let emoji: String
    let imageUrl: String?
    let count: String
    let highlight: Bool
    let reactors: [String]

    func highlighted(_ highlight: Bool) -> ReactionViewModel {
        return ReactionViewModel(emoji: emoji, imageUrl: imageUrl, count: count, highlight: highlight, reactors: reactors)
    }

    static var emptyState: ReactionViewModel {
        return ReactionViewModel(emoji: "❓", imageUrl: nil, count: "?", highlight: false, reactors: [])
    }
}

final class ReactionView: UIView {
    @IBOutlet var contentView: UIView! {
        didSet {
            contentView.layer.borderWidth = 1
            contentView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var emojiView: EmojiView!
    @IBOutlet weak var countLabel: UILabel!

    var tapRecognized: (UITapGestureRecognizer) -> Void = { _ in }
    var longPressRecognized: (UILongPressGestureRecognizer) -> Void = { _ in }

    var model: ReactionViewModel = .emptyState {
        didSet {
            map(model)
        }
    }

    func map(_ model: ReactionViewModel) {
        if let imageUrlString = model.imageUrl, let imageUrl = URL(string: imageUrlString) {
            ImageManager.loadImage(with: imageUrl, into: emojiView.emojiImageView)
        } else {
            emojiView.emojiLabel.text = Emojione.transform(string: model.emoji)
        }

        countLabel.text = model.count

        let colors = model.highlight ? (#colorLiteral(red: 0.3098039216, green: 0.6901960784, blue: 0.9882352941, alpha: 1), #colorLiteral(red: 0.7411764706, green: 0.8823529412, blue: 0.9960784314, alpha: 1), #colorLiteral(red: 0.9529411765, green: 0.9764705882, blue: 1, alpha: 1)) : (#colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1), #colorLiteral(red: 0.9058823529, green: 0.9058823529, blue: 0.9058823529, alpha: 1), #colorLiteral(red: 0.9882352941, green: 0.9882352941, blue: 0.9882352941, alpha: 1))
        countLabel.textColor = colors.0
        contentView.layer.borderColor = colors.1.cgColor
        contentView.backgroundColor = colors.2
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK: Initialization
extension ReactionView {
    private func commonInit() {
        Bundle.main.loadNibNamed("ReactionView", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(tapRecognized(_:)))
        )

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
        longPress.minimumPressDuration = 0.320

        addGestureRecognizer(longPress)
    }
}

// MARK: Gesture Recognizing
extension ReactionView {
    @objc private func tapRecognized(_ sender: UITapGestureRecognizer) {
        tapRecognized(sender)
    }

    @objc private func longPressRecognized(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            longPressRecognized(sender)
        }
    }
}
