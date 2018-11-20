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

    deinit {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    static var current: MainSplitViewController? {
        return (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController as? MainSplitViewController
    }

    static var chatViewController: MessagesViewController? {
        return current?.chatViewController
    }

    static var subscriptionsViewController: SubscriptionsViewController? {
        return current?.subscriptionsViewController
    }

    var chatViewController: MessagesViewController? {
        if let nav = detailViewController as? UINavigationController {
            return nav.viewControllers.first as? MessagesViewController
        } else if let nav = viewControllers.first as? UINavigationController, nav.viewControllers.count >= 2 {
            return nav.viewControllers[1] as? MessagesViewController
        }

        return nil
    }

    var subscriptionsViewController: SubscriptionsViewController? {
        return (viewControllers.first as? UINavigationController)?.viewControllers.first as? SubscriptionsViewController
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ThemeManager.addObserver(self)

        delegate = self
        preferredDisplayMode = .allVisible

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
        SocketManager.reconnect()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return view.theme?.appearence.statusBarStyle ?? .default
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass,
            traitCollection.horizontalSizeClass != .compact,
            let nav = primaryViewController as? UINavigationController,
            let subscriptions = nav.viewControllers.first as? SubscriptionsViewController,
            let subscription = (detailViewController as? MessagesViewController)?.subscription
        else {
            return
        }

        subscriptions.openChat(for: subscription)
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

    func socketDidChangeState(state: SocketConnectionState) {
        if state == .waitingForNetwork || state == .disconnected {
            SocketManager.reconnect()
        }
    }

}

// MARK: Themeable

extension MainSplitViewController {
    override func applyTheme() {
        guard let theme = view.theme else { return }
        view.backgroundColor = theme.mutedAccent
        view.subviews.first?.backgroundColor = theme.mutedAccent
    }
}
