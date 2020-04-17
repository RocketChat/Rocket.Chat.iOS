//
//  AvatarView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/09/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import FLAnimatedImage
import Nuke

final class AvatarView: UIView {
    var avatarPlaceholder: UIImage?
    var imageURL: URL? {
        didSet {
            if let imageURL = imageURL {
                ImageManager.loadImage(with: imageURL, into: imageView) { [weak self] result in
                    if case let .success(response) = result {
                        self?.labelInitials.text = nil
                        self?.backgroundColor = UIColor.clear
                    }
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
        } else if let username = username {
            setAvatarWithInitials(forUsername: username)

            if let avatarURL = User.avatarURL(forUsername: username) {
                imageURL = avatarURL
            }
        }
    }

    lazy var labelInitials: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "?"
        label.textAlignment = .center

        addSubview(label)

        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            label.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        return label
    }()

    var labelInitialsFontSize: CGFloat? {
        didSet {
            labelInitials.font = UIFont.systemFont(ofSize: labelInitialsFontSize ?? 16)
        }
    }

    lazy var imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1),
            imageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        return imageView
    }()

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

        labelInitials.text = initials.uppercased()
        backgroundColor = color
    }

    func refreshCurrentAvatar(withCachedData data: Data, completion: (() -> Void)? = nil) {
        guard let url = imageURL else {
            return
        }

        ImageManager.dataCache?.storeData(data, for: url.absoluteString)
        ImageManager.memoryCache.removeResponse(
            for: ImageRequest(
                url: url
            )
        )

        completion?()
    }

    func prepareForReuse() {
        avatarPlaceholder = nil
        avatarURL = nil
        imageURL = nil
        username = nil
        emoji = nil

        imageView.image = nil
        imageView.animatedImage = nil
        labelInitials.text = ""
    }

    init() {
        super.init(frame: .zero)
        backgroundColor = .black
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: Themeable

extension AvatarView {
    override func applyTheme() {
        super.applyTheme()
        labelInitials.textColor = .white
    }
}
