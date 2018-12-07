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
            contentView.layer.borderWidth = 1.5
            contentView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var emojiView: EmojiView!
    @IBOutlet weak var countLabel: UILabel! {
        didSet {
            countLabel.font = countLabel.font.bold()
        }
    }

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

        self.applyTheme()
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

// MARK: Themeable

extension ReactionView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }

        let colors: (UIColor, UIColor, UIColor) = {
            switch theme {
            case .light: return model.highlight ? (#colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1), #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 0.5), #colorLiteral(red: 0.9098039216, green: 0.9490196078, blue: 1, alpha: 1)) : (#colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1), theme.borderColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            default: return model.highlight ? (#colorLiteral(red: 0, green: 0.56, blue: 0.9882352941, alpha: 0.69), #colorLiteral(red: 0, green: 0.5516742082, blue: 0.9960784314, alpha: 0.26), #colorLiteral(red: 0, green: 0.4999999989, blue: 1, alpha: 0.05)) : (#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.33), theme.borderColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.01))
            }
        }()

        countLabel.textColor = colors.0
        contentView.layer.borderColor = colors.1.cgColor
        contentView.backgroundColor = colors.2
    }
}
