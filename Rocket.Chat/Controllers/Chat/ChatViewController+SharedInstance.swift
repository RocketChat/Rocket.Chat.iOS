//
//  ChatViewController+SharedInstance.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController {
    class func sharedInstance() -> ChatViewController? {
        if let main = MainChatViewController.shared() {
            if let nav = main.centerViewController as? UINavigationController {
                return nav.viewControllers.first as? ChatViewController
            }
        }

        return nil
    }
}
