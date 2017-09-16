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

    static var shared: MainChatViewController? {
        return UIApplication.shared.windows.first?.rootViewController as? MainChatViewController
    }

    class func closeSideMenuIfNeeded() {
        if let instance = shared {
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

        performSegue(withIdentifier: "showCenterController", sender: nil)
        performSegue(withIdentifier: "containSideMenu", sender: nil)
    }

    // MARK: SideMenuControllerDelegate

    func sideMenuControllerWillHide(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.willHide()
    }

    func sideMenuControllerDidHide(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.didHide()
        SubscriptionsPageViewController.shared?.showSubscriptionsList(animated: false)
    }

    func sideMenuControllerDidReveal(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.didReveal()
    }

    func sideMenuControllerWillReveal(_ sideMenuController: SideMenuController) {
        ChatViewController.shared?.textView.resignFirstResponder()
        SubscriptionsViewController.shared?.willReveal()
    }

    // MARK: Authentication & Server management

    func openAddNewTeamController() {
        SocketManager.disconnect { (_, _) in
            self.performSegue(withIdentifier: "Auth", sender: nil)
        }
    }

    func changeSelectedServer(index: Int) {
        DatabaseManager.selectDatabase(at: index)
        DatabaseManager.changeDatabaseInstance(index: index)

        SocketManager.disconnect { (_, _) in
            let storyboardChat = UIStoryboard(name: "Main", bundle: Bundle.main)
            let controller = storyboardChat.instantiateInitialViewController()
            let application = UIApplication.shared

            if let window = application.windows.first {
                window.rootViewController = controller
            }
        }
    }

}
