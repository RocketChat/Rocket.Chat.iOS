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
            UIKeyCommand.init(input: "f", modifierFlags: [.command], action: #selector(shortcutSearchSubscriptions(_:)))
        ] + ((0...9).map({ "\($0)" }) + ["n"]).map { (input: String) -> UIKeyCommand in
                UIKeyCommand(input: input, modifierFlags: .command, action: #selector(shortcutSelectRoom(_:)))
        } + ((0...9).map({ "\($0)" }) + ["`", "n"]).map { (input: String) -> UIKeyCommand in
            UIKeyCommand(input: input, modifierFlags: [.command, .alternate], action: #selector(shortcutSelectServer(_:)))
        }
    }

    @objc func shortcutFocusOnComposer(_ command: UIKeyCommand) {
        chatViewController?.textInputbar.textView.becomeFirstResponder()
        subscriptionsViewController?.searchController?.dismiss(animated: true) { [weak self] in
            self?.chatViewController?.keyboardFrame?.updateFrame()
        }
    }

    @objc func shortcutSearchSubscriptions(_ command: UIKeyCommand) {
        subscriptionsViewController?.searchBar?.becomeFirstResponder()
    }

    @objc func shortcutSelectServer(_ command: UIKeyCommand) {
        guard let input = command.input else {
            return
        }

        switch input {
        case "`":
            subscriptionsViewController?.toggleServersList()
        case "n":
            AppManager.addServer(serverUrl: "")
        default:
            guard let position = Int(input), position > 0 else {
                break
            }

            let index = position - 1

            if index < DatabaseManager.servers?.count ?? 0 {
                AppManager.changeSelectedServer(index: index)
            } else {
                subscriptionsViewController?.openServersList()
            }
        }
    }

    @objc func shortcutSelectRoom(_ command: UIKeyCommand) {
        guard let viewController = subscriptionsViewController, let input = command.input else {
            return
        }

        switch input {
        case "n":
            viewController.performSegue(withIdentifier: "toNewRoom", sender: nil)
        default:
            guard let position = Int(input), position > 0 else {
                break
            }

            viewController.selectRowAt(position - 1)
        }
    }
}
