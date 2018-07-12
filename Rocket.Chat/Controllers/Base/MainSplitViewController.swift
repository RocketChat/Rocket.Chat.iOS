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

    static var chatViewController: ChatViewController? {
        guard
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate,
            let mainViewController = appDelegate.window?.rootViewController as? MainSplitViewController
        else {
            return nil
        }

        return mainViewController.chatViewController
    }

    var chatViewController: ChatViewController? {
        if let nav = detailViewController as? UINavigationController {
            return nav.viewControllers.first as? ChatViewController
        } else if let nav = viewControllers.first as? UINavigationController, nav.viewControllers.count >= 2 {
            return nav.viewControllers[1] as? ChatViewController
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

extension MainSplitViewController {
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand.init(input: "\t", modifierFlags: [], action: #selector(shortcutFocusOnComposer(_:))),
            UIKeyCommand.init(input: "\t", modifierFlags: .shift, action: #selector(shortcutFocusOnSearch(_:)))
        ]
    }

    @objc func shortcutFocusOnComposer(_ command: UIKeyCommand) {
        chatViewController?.textInputbar.textView.becomeFirstResponder()
        subscriptionsViewController?.searchController?.dismiss(animated: true) { [weak self] in
            self?.chatViewController?.keyboardFrame?.updateFrame()
        }
    }

    @objc func shortcutFocusOnSearch(_ command: UIKeyCommand) {
        subscriptionsViewController?.searchBar?.becomeFirstResponder()
    }
}
