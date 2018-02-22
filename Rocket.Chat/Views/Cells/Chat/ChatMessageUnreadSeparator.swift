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

    static let identifier = "ChatMessageDaySeparator"

    @IBOutlet weak var labelTitle: UILabel!
}
