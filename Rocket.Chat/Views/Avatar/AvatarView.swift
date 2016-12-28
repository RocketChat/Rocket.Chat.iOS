//
//  AvatarView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/09/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

let avatarColors: [UInt] = [
    0xF44336, 0xE91E63, 0x9C27B0, 0x673AB7, 0x3F51B5,
    0x2196F3, 0x03A9F4, 0x00BCD4, 0x009688, 0x4CAF50,
    0x8BC34A, 0xCDDC39, 0xFFC107, 0xFF9800, 0xFF5722,
    0x795548, 0x9E9E9E, 0x607D8B]

class AvatarView: BaseView {

    var user: User! {
        didSet {
            updateAvatar()
        }
    }

    @IBOutlet weak var labelInitials: UILabel!
    var labelInitialsFontSize: CGFloat? {
        didSet {
            labelInitials?.font = UIFont.systemFont(ofSize: labelInitialsFontSize!)
        }
    }

    @IBOutlet weak var imageView: UIImageView!

    private func userAvatarURL() -> URL? {
        guard let username = user.username else { return nil }
        guard let auth = AuthManager.isAuthenticated() else { return nil }
        guard let serverURL = NSURL(string: auth.serverURL) else { return nil }
        return URL(string: "http://\(serverURL.host!)/avatar/\(username).jpg")!
    }

    private func updateAvatar() {
        setAvatarWithInitials()

        if let imageURL = userAvatarURL() {
            imageView.sd_setImage(with: imageURL, completed: { [weak self] _, error, _, _ in
                guard let _ = error else {
                    self?.labelInitials.text = ""
                    self?.backgroundColor = UIColor.clear
                    return
                }

                self?.setAvatarWithInitials()
            })
        }
    }

    private func setAvatarWithInitials() {
        let username = user.username ?? "?"

        var initials = ""
        var color: UInt = 0x000000

        if username == "?" {
            initials = username
            color = 0x000000
        } else {
            let position = username.characters.count % avatarColors.count
            color = avatarColors[position]

            let strings = username.components(separatedBy: ".")
            if let first = strings.first, let last = strings.last {
                let lastOffset = strings.count > 1 ? 1 : 2
                let indexFirst = first.index(first.startIndex, offsetBy: 1)
                let indexLast = last.index(last.startIndex, offsetBy: lastOffset)

                let firstString = first.substring(to: indexFirst)
                var lastString = last.substring(to: indexLast)

                if lastOffset == 2 {
                    let endIndex = lastString.index(lastString.startIndex, offsetBy: 1)
                    lastString = lastString.substring(from: endIndex)
                }

                initials = "\(firstString)\(lastString)"
            }
        }

        labelInitials.text = initials.uppercased()
        backgroundColor = UIColor(rgb: color, alphaVal: 1)
    }

    // MARK: Replaceable

    override func isReplaceable() -> Bool {
        return true
    }
}
