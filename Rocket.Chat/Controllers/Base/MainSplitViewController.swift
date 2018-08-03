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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass,
            traitCollection.horizontalSizeClass != .compact,
            let nav = primaryViewController as? UINavigationController,
            let subscriptions = nav.viewControllers.first as? SubscriptionsViewController,
            let subscription = (detailViewController as? ChatViewController)?.subscription
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

// MARK: Keyboard Shortcuts

extension MainSplitViewController {
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "\t", modifierFlags: [], action: #selector(shortcutFocusOnComposer(_:)), discoverabilityTitle: "Type message"),
            UIKeyCommand(input: "p", modifierFlags: .command, action: #selector(shortcutTogglePreferences(_:)), discoverabilityTitle: "Preferences"),
            UIKeyCommand(input: "f", modifierFlags: [.command, .alternate], action: #selector(shortcutRoomSearch(_:)), discoverabilityTitle: "Rooms search"),
            UIKeyCommand(input: "1...9", modifierFlags: .command, action: #selector(shortcutSelectRoom(_:)), discoverabilityTitle: "Room selection 1...9"),
            UIKeyCommand(input: "]", modifierFlags: .command, action: #selector(shortcutSelectRoom(_:)), discoverabilityTitle: "Next room"),
            UIKeyCommand(input: "[", modifierFlags: .command, action: #selector(shortcutSelectRoom(_:)), discoverabilityTitle: "Previous room"),
            UIKeyCommand(input: "n", modifierFlags: .command, action: #selector(shortcutSelectRoom(_:)), discoverabilityTitle: "New room"),
            UIKeyCommand(input: "i", modifierFlags: .command, action: #selector(shortcutRoomActions(_:)), discoverabilityTitle: "Room actions"),
            UIKeyCommand(input: "u", modifierFlags: .command, action: #selector(shortcutUpload(_:)), discoverabilityTitle: "Upload to room"),
            UIKeyCommand(input: "f", modifierFlags: .command, action: #selector(shortcutRoomActions(_:)), discoverabilityTitle: "Search messages"),
            UIKeyCommand(input: "↑ ↓", modifierFlags: .alternate, action: #selector(shortcutScrollMessages(_:)), discoverabilityTitle: "Scroll messages"),
            UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .alternate, action: #selector(shortcutScrollMessages(_:))),
            UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .alternate, action: #selector(shortcutScrollMessages(_:))),
            UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(shortcutReplyLatest(_:)), discoverabilityTitle: "Reply to latest"),
            UIKeyCommand(input: "`", modifierFlags: [.command, .alternate], action: #selector(shortcutSelectServer(_:)), discoverabilityTitle: "Server selection"),
            UIKeyCommand(input: "1...9", modifierFlags: [.command, .alternate], action: #selector(shortcutSelectServer(_:)), discoverabilityTitle: "Server selection 1...9"),
            UIKeyCommand(input: "n", modifierFlags: [.command, .alternate], action: #selector(shortcutSelectServer(_:)), discoverabilityTitle: "Add server")
        ] + ((0...9).map({ "\($0)" })).map { (input: String) -> UIKeyCommand in
                UIKeyCommand(input: input, modifierFlags: .command, action: #selector(shortcutSelectRoom(_:)))
        } + ((0...9).map({ "\($0)" })).map { (input: String) -> UIKeyCommand in
            UIKeyCommand(input: input, modifierFlags: [.command, .alternate], action: #selector(shortcutSelectServer(_:)))
        } + [
            UIKeyCommand(input: "t", modifierFlags: .command, action: #selector(shortcutChangeTheme(_:)), discoverabilityTitle: "Change theme")
        ]
    }

    @objc func shortcutFocusOnComposer(_ command: UIKeyCommand) {
        guard let textView = chatViewController?.textInputbar.textView else {
            return
        }

        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
            subscriptionsViewController?.searchController?.dismiss(animated: true) { [weak self] in
                self?.chatViewController?.keyboardFrame?.updateFrame()
            }
        }
    }

    @objc func shortcutTogglePreferences(_ command: UIKeyCommand) {
        subscriptionsViewController?.togglePreferences()
    }

    @objc func shortcutRoomSearch(_ command: UIKeyCommand) {
        if subscriptionsViewController?.searchBar?.isFirstResponder ?? false {
            subscriptionsViewController?.searchController?.dismiss(animated: true, completion: nil)
        } else {
            subscriptionsViewController?.searchBar?.becomeFirstResponder()
        }
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
        case "]":
            viewController.selectNextRoom()
        case "[":
            viewController.selectPreviousRoom()
        default:
            guard let position = Int(input), position > 0 else {
                break
            }

            viewController.selectRoomAt(position - 1)
        }
    }

    @objc func shortcutUpload(_ command: UIKeyCommand) {
        if let presented = chatViewController?.presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.chatViewController?.buttonUploadDidPressed()
            }
        } else {
            chatViewController?.buttonUploadDidPressed()
        }
    }

    @objc func shortcutRoomActions(_ command: UIKeyCommand) {
        chatViewController?.toggleActions()
    }

    @objc func shortcutScrollMessages(_ command: UIKeyCommand) {
        guard
            let input = command.input,
            let offset = chatViewController?.collectionView?.contentOffset,
            let maxHeight = chatViewController?.collectionView?.contentSize.height,
            let collectionView = chatViewController?.collectionView
        else {
            return
        }

        let heightDelta: CGFloat = input == UIKeyInputUpArrow ? -50.0 : 50.0

        UIView.animate(withDuration: 0.1, animations: { [weak collectionView] in
            let offset = min(offset.y + heightDelta, maxHeight)
            collectionView?.contentOffset = CGPoint(x: 0, y: offset)
        })
    }

    @objc func shortcutReplyLatest(_ command: UIKeyCommand) {
        if let message = chatViewController?.subscription?.roomLastMessage {
            chatViewController?.reply(to: message)
        }
    }

    @objc func shortcutChangeTheme(_ command: UIKeyCommand) {
        if let currentThemeIndex = ThemeManager.themes.index(where: { $0.title == ThemeManager.themeTitle }) {
            if ThemeManager.themes.count > currentThemeIndex + 1 {
                ThemeManager.theme = ThemeManager.themes[currentThemeIndex + 1].theme
            } else {
                ThemeManager.theme = ThemeManager.themes.first?.theme ?? .light
            }
        }
    }
}
