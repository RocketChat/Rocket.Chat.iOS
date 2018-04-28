//
//  EmojiAutocompleteCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class EmojiAutocompleteCell: UITableViewCell {
    static let identifier = "EmojiAutocompleteCell"

    @IBOutlet weak var emojiView: EmojiView!
    @IBOutlet weak var shortnameLabel: UILabel!

    var shortname: String? {
        set {
            if let string = newValue {
                shortnameLabel.attributedText = NSAttributedString(string: string)
            }
        }

        get {
            return shortnameLabel.attributedText?.string
        }
    }

    func highlight(string: String) {
        if let attributedString = shortnameLabel.attributedText {
            let attributedString = NSMutableAttributedString(string: attributedString.string)

            if let range = attributedString.string.range(of: string) {
                attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(range, in: attributedString.string))

                shortnameLabel.attributedText = attributedString
            }
        }
    }

    override func prepareForReuse() {
        emojiView.emojiLabel.text = ""
        emojiView.emojiImageView.image = nil
        emojiView.emojiImageView.animatedImage = nil
    }
}
