//
//  MessagesViewControllerSearching.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension MessagesViewController {

    @objc func showSearchMessages() {
        guard
            let controller = storyboard?.instantiateViewController(withIdentifier: "MessagesList"),
            let messageList = controller as? MessagesListViewController
        else {
            return
        }

        messageList.data.subscription = subscription
        messageList.data.isSearchingMessages = true
        let searchMessagesNav = BaseNavigationController(rootViewController: messageList)

        present(searchMessagesNav, animated: true, completion: nil)

    }

}
