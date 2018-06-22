//
//  ChatMessageUnreadSeparator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatMessageUnreadSeparator: UICollectionViewCell {
    static var minimumHeight: CGFloat = 40
    static let identifier = "ChatMessageUnreadSeparator"

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var seperatorLine: UIView!
}

// MARK: Themeable

extension ChatMessageUnreadSeparator {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        seperatorLine.backgroundColor = theme.strongAccent
        labelTitle.textColor = theme.strongAccent
    }
}
