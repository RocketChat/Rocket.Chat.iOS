//
//  ChatDirectMessageHeaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 24/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatDirectMessageHeaderCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(200)
    static let identifier = "ChatDirectMessageHeaderCell"

    var subscription: Subscription? {
        didSet {
            guard let user = subscription?.directMessageUser else { return }
            labelUser.text = user.displayName()
            avatarView.user = user
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    weak var avatarView: AvatarView! {
        didSet {
            avatarView.layer.cornerRadius = 4
            avatarView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var labelStartConversation: UILabel!

}
