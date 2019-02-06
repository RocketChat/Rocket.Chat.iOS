//
//  ChatMessageDaySeparator.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatMessageDaySeparator: UICollectionViewCell {
    static let minimumHeight: CGFloat = 40.0
    static let identifier = "ChatMessageDaySeparator"

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var seperatorLine: UIView!
}

// MARK: Themeable

extension ChatMessageDaySeparator {
    override func applyTheme() {
        super.applyTheme()
        seperatorLine.backgroundColor = #colorLiteral(red: 0.491, green: 0.4938107133, blue: 0.500592351, alpha: 0.1964201627)
    }
}
