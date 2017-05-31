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
        chatHeaderViewStatus?.removeFromSuperview()

        DispatchQueue.main.async { [weak self] in
            if let subscription = self?.subscription {
                self?.subscription = subscription
            }
        }

        rightButton.isEnabled = true
    }

    func socketDidDisconnect(socket: SocketManager) {
        chatHeaderViewStatus?.removeFromSuperview()

        if let headerView = ChatHeaderViewStatus.instantiateFromNib() {
            headerView.injectionContainer = injectionContainer
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
            view.addSubview(headerView)
            chatHeaderViewStatus = headerView

            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[headerView]-0-|",
                options: .alignAllLeft,
                metrics: nil,
                views: ["headerView": headerView])
            )

            view.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[headerView(44)]",
                options: .alignAllLeft,
                metrics: nil,
                views: ["headerView": headerView])
            )
        }
    }

}
