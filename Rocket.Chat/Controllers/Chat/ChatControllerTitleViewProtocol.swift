//
//  ChatControllerTitleViewProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController: ChatTitleViewProtocol {
    private func showSearchMessages() {
        guard
            let storyboard = storyboard,
            let messageList = storyboard.instantiateViewController(withIdentifier: "MessagesList") as? MessagesListViewController
            else {
                return
        }

        messageList.data.subscription = subscription
        messageList.data.isSearchingMessages = true
        let searchMessagesNav = BaseNavigationController(rootViewController: messageList)

        present(searchMessagesNav, animated: true, completion: nil)
    }

    func titleViewChannelButtonPressed() {
        performSegue(withIdentifier: "Channel Actions", sender: nil)
    }

    func titleViewSearchButtonPressed() {
        self.showSearchMessages()
    }
}
