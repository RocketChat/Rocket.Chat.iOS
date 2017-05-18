//
//  ChatViewControllerDelegation.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatViewControllerDelegation: ChatViewControllerDelegate {
    func chatViewController(_ chatViewController: ChatViewController, didUpdateWithSubscription subscription: Subscription?) {
        if chatViewController.closeSidebarAfterSubscriptionUpdate {
            MainChatViewController.closeSideMenuIfNeeded()
            chatViewController.closeSidebarAfterSubscriptionUpdate = false
        }
    }
}
