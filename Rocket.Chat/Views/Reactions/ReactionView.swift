//
//  ReactionView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct ReactionViewModel {
    let emoji: String
    let count: String
}

class ReactionView: UIView {
    @IBOutlet var contentView: UIView! {
        didSet {
            contentView.layer.borderColor = UIColor.gray.cgColor
            contentView.layer.borderWidth = 1
            contentView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var emojiImageView: UIImageView!
    @IBOutlet weak var emojiLabel: UILabel!

    @IBOutlet weak var countLabel: UILabel!

    var model: ReactionViewModel = ReactionViewModel(emoji: "❓", count: "?") {
        didSet {
            map(model)
        }
    }

    func map(_ model: ReactionViewModel) {
        emojiLabel.text = Emojione.transform(string: model.emoji)
        countLabel.text = model.count
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
    }
}
