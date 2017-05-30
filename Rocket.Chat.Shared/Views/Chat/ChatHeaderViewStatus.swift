//
//  ChatHeaderViewStatus.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatHeaderViewStatus: UIView, SocketManagerInjected {

    static let defaultHeight = CGFloat(44)
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.text = localized("connection.offline.banner.message")
        }
    }

    @IBOutlet weak var buttonRefresh: UIButton!

    var injectionContainer: InjectionContainer!

    @IBAction func buttonRefreshDidPressed(_ sender: Any) {
        socketManager.reconnect()
    }

}
