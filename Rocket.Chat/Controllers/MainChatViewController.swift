//
//  MainChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 15/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SideMenuController

class MainChatViewController: SideMenuController, SideMenuControllerDelegate {

    class func shared() -> MainChatViewController? {
        return UIApplication.shared.windows.first?.rootViewController as? MainChatViewController
    }

    class func closeSideMenuIfNeeded() {
        if let instance = shared() {
            if instance.sidePanelVisible {
                instance.toggle()
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "Menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .underCenterPanelLeft

        if UIDevice.current.userInterfaceIdiom == .pad {
            SideMenuController.preferences.drawing.sidePanelWidth = 320
        } else {
            SideMenuController.preferences.drawing.sidePanelWidth = UIScreen.main.bounds.width -
                30
        }

        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.interaction.swipingEnabled = true
        SideMenuController.preferences.interaction.panningEnabled = true
        SideMenuController.preferences.animating.statusBarBehaviour = .slideAnimation
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        performSegue(withIdentifier: "showCenterController", sender: nil)
        performSegue(withIdentifier: "containSideMenu", sender: nil)
    }

    // MARK: SideMenuControllerDelegate

    func sideMenuControllerWillHide(_ sideMenuController: SideMenuController) {
        ChatViewController.sharedInstance()?.textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

    func sideMenuControllerDidHide(_ sideMenuController: SideMenuController) {
        ChatViewController.sharedInstance()?.textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

    func sideMenuControllerDidReveal(_ sideMenuController: SideMenuController) {
        ChatViewController.sharedInstance()?.textView.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
    }

    func sideMenuControllerWillReveal(_ sideMenuController: SideMenuController) {
        ChatViewController.sharedInstance()?.textView.resignFirstResponder()

        SubscriptionsViewController.sharedInstance()?.textFieldSearch.resignFirstResponder()
        SubscriptionsViewController.sharedInstance()?.updateData()
    }

}
