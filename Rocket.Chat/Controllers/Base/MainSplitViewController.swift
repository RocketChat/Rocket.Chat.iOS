//
//  MainSplitViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 21/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class MainSplitViewController: UISplitViewController {

    let socketHandlerToken = String.random(5)

    var chatViewController: ChatViewController? {
        var controller: ChatViewController?

        if let nav = detailViewController as? UINavigationController {
            if let chatController = nav.viewControllers.first as? ChatViewController {
                controller = chatController
            }
        } else if let nav = viewControllers.first as? UINavigationController, nav.viewControllers.count >= 2 {
            if let chatController = nav.viewControllers[1] as? ChatViewController {
                controller = chatController
            }
        }

        return controller
    }

    deinit {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        delegate = self
        preferredDisplayMode = .allVisible

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
        SocketManager.reconnect()
    }

}

// MARK: UISplitViewControllerDelegate

extension MainSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}

// MARK: SocketConnectionHandler

extension MainSplitViewController: SocketConnectionHandler {

    func socketDidConnect(socket: SocketManager) {

    }

    func socketDidDisconnect(socket: SocketManager) {
        SocketManager.reconnect()
    }

    func socketDidReturnError(socket: SocketManager, error: SocketError) {
        // Handle errors
    }

}
