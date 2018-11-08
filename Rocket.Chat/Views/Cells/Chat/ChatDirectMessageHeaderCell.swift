//
//  ChatDirectMessageHeaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 24/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatDirectMessageHeaderCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(240)
    static let identifier = "ChatDirectMessageHeaderCell"

    var subscription: Subscription? {
        didSet {
            guard subscription?.directMessageUser != nil else {
                return fetchUser()
            }

            updateUser()
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarView.frame = avatarViewContainer.bounds
            avatarViewContainer.addSubview(avatarView)
        }
    }

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true
        return avatarView
    }()

    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var labelStartConversation: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.username = nil
        labelUser.text = ""
        labelStartConversation.text = ""
    }

    func updateUser() {
        guard let user = subscription?.directMessageUser else {
            labelUser.text = ""
            labelStartConversation.text = ""
            return
        }

        labelUser.text = user.displayName()
        avatarView.username = user.username

        let startText = localized("chat.dm.start_conversation")
        labelStartConversation.text = String(format: startText, user.displayName())
    }

    func fetchUser() {
        guard
            let userId = subscription?.otherUserId,
            !userId.isEmpty
        else {
            updateUser()
            return
        }

        User.fetch(by: .userId(userId), completion: { _ in
            self.updateUser()
        })
    }

}
