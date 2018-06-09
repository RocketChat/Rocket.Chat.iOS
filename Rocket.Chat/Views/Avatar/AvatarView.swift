//
//  AvatarView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/09/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage

final class AvatarView: UIView {

    var avatarPlaceholder: UIImage?
    var imageURL: URL? {
        didSet {
            if let imageURL = imageURL {
                ImageManager.loadImage(with: imageURL, into: imageView) { [weak self] _, error in
                    guard error == nil else { return }

                    self?.labelInitials.text = ""
                    self?.backgroundColor = UIColor.clear
                }
            }
        }
    }

    var avatarURL: URL? {
        didSet {
            updateAvatar()
        }
    }

    var subscription: Subscription? {
        didSet {
            updateAvatar()
        }
    }

    var user: User? {
        didSet {
            updateAvatar()
        }
    }

    var emoji: String? {
        didSet {
            if emoji != nil {
                updateAvatar()
            }
        }
    }

    var username: String? {
        didSet {
            if username != nil {
                updateAvatar()
            }
        }
    }

    func updateAvatar() {
        if let emoji = emoji {
            let emojiCharacter = Emojione.transform(string: emoji)

            if emojiCharacter != emoji {
                labelInitials.text = emojiCharacter
            } else if let imageUrl = CustomEmoji.withShortname(emoji)?.imageUrl() {
                imageURL = URL(string: imageUrl)
            }

            backgroundColor = .clear
        } else if let avatarURL = avatarURL {
            imageURL = avatarURL
        } else if let user = user {
            setAvatarWithInitials(forUsername: user.username)

            if let avatarURL = user.avatarURL() {
                imageURL = avatarURL
            }
        } else if let avatarURL = subscription?.avatarURL() {
            setAvatarWithInitials(forUsername: subscription?.name)
            imageURL = avatarURL
        } else if let username = username, let avatarURL = User.avatarURL(forUsername: username) {
            imageURL = avatarURL
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

    private func setAvatarWithInitials(forUsername username: String?) {
        let username = username ?? "?"
        var initials = "?"
        var color = UIColor.black

        if username == "?" {
            initials = username
        } else {
            let position = username.count % UIColor.avatarColors.count
            color = UIColor.avatarColors[position]
            initials = initialsFor(username)
        }

        labelInitials?.text = initials.uppercased()
        backgroundColor = color
    }

    func prepareForReuse() {
        avatarPlaceholder = nil
        avatarURL = nil
        imageURL = nil
        user = nil
        subscription = nil
        emoji = nil

        imageView.image = nil
        imageView.animatedImage = nil

        labelInitials.text = ""
    }

}
