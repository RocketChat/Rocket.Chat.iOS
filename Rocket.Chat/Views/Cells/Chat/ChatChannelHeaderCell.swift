//
//  ChatChannelHeaderCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 26/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatChannelHeaderCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(200)
    static let identifier = "ChatChannelHeaderCell"

    var subscription: Subscription? {
        didSet {
            labelTitle.text = subscription?.displayName()

            let startText = localized("chat.channel.start_conversation")
            labelStartConversation.text = String(format: startText, subscription?.displayName() ?? "")
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelStartConversation: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        labelTitle.text = ""
        labelStartConversation.text = ""
    }

}
