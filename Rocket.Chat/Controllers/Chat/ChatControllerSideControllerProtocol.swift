//
//  ChatControllerSideControllerProtocol.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SideMenuController

extension ChatViewController: SideMenuControllerDelegate {

    func setupSideMenuDelegateHandling() {
        MainChatViewController.shared()?.delegate = self
    }

    // MARK: SideMenuControllerDelegate

    func sideMenuControllerWillHide(_ sideMenuController: SideMenuController) {
        textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

    func sideMenuControllerDidHide(_ sideMenuController: SideMenuController) {
        textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

    func sideMenuControllerDidReveal(_ sideMenuController: SideMenuController) {
        textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

    func sideMenuControllerWillReveal(_ sideMenuController: SideMenuController) {
        textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

}
