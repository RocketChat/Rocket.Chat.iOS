//
//  MainSplitViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 21/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class MainSplitViewController: UISplitViewController {

    static var chatViewController: ChatViewController? {
        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let mainViewController = appDelegate.window?.rootViewController as? MainSplitViewController
        else {
            return nil
        }

        var controller: ChatViewController?

        if let nav = mainViewController.detailViewController as? UINavigationController {
            if let chatController = nav.viewControllers.first as? ChatViewController {
                controller = chatController
            }
        } else if let nav = mainViewController.viewControllers.first as? UINavigationController, nav.viewControllers.count >= 2 {
            if let chatController = nav.viewControllers[1] as? ChatViewController {
                controller = chatController
            }
        }

        return controller
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        delegate = self
        preferredDisplayMode = .allVisible

        SocketManager.reconnect()
    }

}

// MARK: UISplitViewControllerDelegate

extension MainSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }

}
