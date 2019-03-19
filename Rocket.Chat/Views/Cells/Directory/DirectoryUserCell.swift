//
//  DirectoryUserCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

final class DirectoryUserCell: UITableViewCell {

    static let identifier = String(describing: DirectoryUserCell.self)

    var user: UnmanagedUser? {
        didSet {
            if user != nil {
                updateUserInformation()
            }
        }
    }

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelServer: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        user = nil
        imageViewAvatar.image = nil
        labelName.text = nil
        labelUsername.text = nil
        labelServer.text = nil
    }

    // MARK: Data Management

    func updateUserInformation() {
        if let avatarURL = user?.avatarURL {
            ImageManager.loadImage(with: avatarURL, into: imageViewAvatar) { _, _ in }
        }

        labelName.text = user?.name
        labelUsername.text = user?.username
        labelServer.text = user?.federatedServerName
    }

}

// MARK: Themeable

extension DirectoryUserCell {

    override func applyTheme() {
        super.applyTheme()

        guard let theme = theme else { return }

        labelName.textColor = theme.bodyText
        labelUsername.textColor = theme.auxiliaryText
        labelServer.textColor = theme.auxiliaryText
    }

}
