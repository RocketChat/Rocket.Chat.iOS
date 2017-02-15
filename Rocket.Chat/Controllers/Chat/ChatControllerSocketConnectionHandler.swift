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
        chatHeaderViewOffline?.removeFromSuperview()

        DispatchQueue.main.async { [weak self] in
            if let subscription = self?.subscription {
                self?.subscription = subscription
            }
        }

        rightButton.isEnabled = true
    }

    func socketDidDisconnect(socket: SocketManager) {
        chatHeaderViewOffline?.removeFromSuperview()

        if let headerView = ChatHeaderViewOffline.instantiateFromNib() {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerView.frame.height)
            view.addSubview(headerView)
            chatHeaderViewOffline = headerView
        }
    }

}
