//
//  AvatarView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/09/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage
import SDWebImage

let avatarColors: [UInt] = [
    0xF44336, 0xE91E63, 0x9C27B0, 0x673AB7, 0x3F51B5,
    0x2196F3, 0x03A9F4, 0x00BCD4, 0x009688, 0x4CAF50,
    0x8BC34A, 0xCDDC39, 0xFFC107, 0xFF9800, 0xFF5722,
    0x795548, 0x9E9E9E, 0x607D8B]

final class AvatarView: UIView {

    var imageURL: URL? {
        didSet {
            if let imageURL = imageURL {
                let options: SDWebImageOptions = [.retryFailed, .scaleDownLargeImages, .highPriority]
                imageView?.sd_setImage(with: imageURL, placeholderImage: nil, options: options) { [weak self] (_, error, _, _) in
                    guard error == nil else { return }

                    self?.labelInitials.text = ""
                    self?.backgroundColor = UIColor.clear
                }
            }
        }
    }

    var avatarURL: URL? {
        didSet {
            if avatarURL != nil {
                updateAvatar()
            }
        }
    }

    var user: User? {
        didSet {
            if user != nil {
                updateAvatar()
            }
        }
    }

    var emoji: String? {
        didSet {
            if emoji != nil {
                updateAvatar()
            }
        }
    }

    func updateAvatar() {
        setAvatarWithInitials()

        if let emoji = emoji {
            let emojiCharacter = Emojione.transform(string: emoji)

            if emojiCharacter != emoji {
                labelInitials.text = emojiCharacter
            } else if let imageUrl = CustomEmoji.withShortname(emoji)?.imageUrl() {
                imageURL = URL(string: imageUrl)
            }

            backgroundColor = .clear
        } else if let avatarURL = avatarURL {
            self.imageURL = avatarURL
        } else if let avatarURL = user?.avatarURL() {
            self.imageURL = avatarURL
        }
    }

    @IBOutlet weak var labelInitials: UILabel!
    var labelInitialsFontSize: CGFloat? {
        didSet {
            labelInitials?.font = UIFont.systemFont(ofSize: labelInitialsFontSize ?? 16)
        }
    }

    @IBOutlet weak var imageView: FLAnimatedImageView!

    internal func initialsFor(_ username: String) -> String {
        guard username.count > 0 else {
            return "?"
        }

        let strings = username.components(separatedBy: ".")

        if let first = strings.first, let last = strings.last {
            if first.isEmpty || last.isEmpty {
                return "?"
            }

            let lastOffset = strings.count > 1 ? 1 : 2
            let indexFirst = first.index(first.startIndex, offsetBy: 1)
            let firstString = first[..<indexFirst]

            var lastString: Substring = ""
            if last.count >= lastOffset {
                let indexLast = last.index(last.startIndex, offsetBy: lastOffset)
                lastString = last[..<indexLast]

                if lastOffset == 2 {
                    let endIndex = lastString.index(lastString.startIndex, offsetBy: 1)
                    lastString = lastString[endIndex...]
                }
            }

            return "\(firstString)\(lastString)".uppercased()
        }

        return ""
    }

    private func setAvatarWithInitials() {
        guard let user = user, !user.isInvalidated else {
            labelInitials?.text = "?"
            backgroundColor = .black
            return
        }

        let username = user.username ?? "?"
        var initials = ""
        var color: UInt = 0x000000

        if username == "?" {
            initials = username
            color = 0x000000
        } else {
            let position = username.count % avatarColors.count
            color = avatarColors[position]
            initials = initialsFor(username)
        }

        labelInitials?.text = initials.uppercased()
        backgroundColor = UIColor(rgb: color, alphaVal: 1)
    }

    func prepareForReuse() {
        avatarURL = nil
        imageURL = nil
        user = nil
        emoji = nil

        imageView.image = nil
        imageView.animatedImage = nil

        labelInitials.text = ""
    }

}
