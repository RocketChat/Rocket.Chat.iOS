//
//  ChatHeaderViewStatus.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatHeaderViewStatus: UIView {

    static let defaultHeight = CGFloat(44)
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.text = localized("connection.offline.banner.message")
        }
    }

    @IBOutlet weak var buttonRefresh: UIButton!

    @IBAction func buttonRefreshDidPressed(_ sender: Any) {
        SocketManager.reconnect()
    }

}
