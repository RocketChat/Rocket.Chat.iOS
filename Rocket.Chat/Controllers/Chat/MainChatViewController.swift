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
    let infoRequestHandler = InfoRequestHandler()
    let socketHandlerToken = String.random(5)

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

        delegate = self

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        if let auth = AuthManager.isAuthenticated() {
            if let apiHost = auth.apiHost {
                infoRequestHandler.delegate = self
                infoRequestHandler.validate(with: apiHost)
            }
        }

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

    func logout() {
        ChatViewController.shared?.messagesToken?.invalidate()
        ChatViewController.shared?.subscriptionToken?.invalidate()
        SubscriptionsViewController.shared?.currentUserToken?.invalidate()
        SubscriptionsViewController.shared?.subscriptionsToken?.invalidate()

        AuthManager.logout {
            AppManager.reloadApp()
        }
    }

    func openAddNewTeamController() {
        SocketManager.disconnect { (_, _) in }
        WindowManager.open(.auth)
    }
}

extension MainChatViewController: SocketConnectionHandler {

    func socketDidConnect(socket: SocketManager) {

    }

    func socketDidDisconnect(socket: SocketManager) {

    }

    func socketDidReturnError(socket: SocketManager, error: SocketError) {
        switch error.error {
        case .invalidUser:
            let alert = UIAlertController(
                title: localized("alert.socket_error.invalid_user.title"),
                message: localized("alert.socket_error.invalid_user.message"),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: { _ in
                self.logout()
            }))

            self.present(alert, animated: true, completion: nil)
        default: break
        }
    }

}

extension MainChatViewController: InfoRequestHandlerDelegate {

    var viewControllerToPresentAlerts: UIViewController? { return self }

    func urlNotValid() {
        // Do nothing
    }

    func serverIsValid() {
        // Do nothing
    }

    func serverChangedURL(_ newURL: String?) {
        guard
            let url = URL(string: newURL ?? ""),
            let socketURL = url.socketURL()
        else {
            return WindowManager.open(.chat)
        }

        let newIndex = DatabaseManager.copyServerInformation(
            from: DatabaseManager.selectedIndex,
            with: socketURL.absoluteString
        )

        DatabaseManager.selectDatabase(at: newIndex)
        DatabaseManager.cleanInvalidDatabases()
        DatabaseManager.changeDatabaseInstance()
        AuthManager.recoverAuthIfNeeded()

        DispatchQueue.main.async {
            guard
                let auth = AuthManager.isAuthenticated(),
                let apiHost = auth.apiHost
            else {
                return
            }

            self.infoRequestHandler.validate(with: apiHost)
        }
    }

}
