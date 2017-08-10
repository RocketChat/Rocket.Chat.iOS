//
//  ChatControllerHeaderStatus.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController {

    func showHeaderStatusView() {
        chatHeaderViewStatus?.removeFromSuperview()

        if let headerView = ChatHeaderViewStatus.instantiateFromNib() {
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

    func hideHeaderStatusView() {
        chatHeaderViewStatus?.removeFromSuperview()
    }

}
