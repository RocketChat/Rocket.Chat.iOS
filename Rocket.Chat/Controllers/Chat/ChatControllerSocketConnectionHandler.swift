//
//  ChatControllerSocketConnectionHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController: SocketConnectionHandler {
    func socketDidConnect(socket: SocketManager) {
        hideHeaderStatusView()

        DispatchQueue.main.async { [weak self] in
            if let subscription = self?.subscription {
                self?.subscription = subscription
            }
        }

        rightButton.isEnabled = true
    }

    func socketDidDisconnect(socket: SocketManager) {
        showHeaderStatusView()

        chatHeaderViewStatus?.labelTitle.text = localized("connection.offline.banner.message")
        chatHeaderViewStatus?.buttonRefresh.isHidden = false
        chatHeaderViewStatus?.backgroundColor = .RCLightGray()
        chatHeaderViewStatus?.setTextColor(.RCDarkBlue())
    }

    func socketDidReturnError(socket: SocketManager, error: SocketError) {
        // handle errors
    }
}
