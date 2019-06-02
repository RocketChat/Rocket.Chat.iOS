//
//  MainSplitViewControllerShortcuts.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 8/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

// MARK: Keyboard Shortcuts

extension MainSplitViewController {
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(
                input: "\t",
                modifierFlags: [],
                action: #selector(shortcutFocusOnComposer(_:)),
                discoverabilityTitle: localized("shortcuts.type_message")
            ),
            UIKeyCommand(
                input: "p",
                modifierFlags: .command,
                action: #selector(shortcutTogglePreferences(_:)),
                discoverabilityTitle: localized("shortcuts.preferences")
            ),
            UIKeyCommand(
                input: "f",
                modifierFlags: [.command, .alternate],
                action: #selector(shortcutRoomSearch(_:)),
                discoverabilityTitle: localized("shortcuts.room_search")
            ),
            UIKeyCommand(
                input: "1...9",
                modifierFlags: .command,
                action: #selector(shortcutSelectRoom(_:)),
                discoverabilityTitle: localized("shortcuts.room_selection")
            ),
            UIKeyCommand(
                input: "]",
                modifierFlags: .command,
                action: #selector(shortcutSelectRoom(_:)),
                discoverabilityTitle: localized("shortcuts.next_room")
            ),
            UIKeyCommand(
                input: "[",
                modifierFlags: .command,
                action: #selector(shortcutSelectRoom(_:)),
                discoverabilityTitle: localized("shortcuts.previous_room")
            ),
            UIKeyCommand(
                input: "n",
                modifierFlags: .command,
                action: #selector(shortcutSelectRoom(_:)),
                discoverabilityTitle: localized("shortcuts.new_room")
            ),
            UIKeyCommand(
                input: "i",
                modifierFlags: .command,
                action: #selector(shortcutRoomActions(_:)),
                discoverabilityTitle: localized("shortcuts.room_actions")
            ),
            UIKeyCommand(
                input: "u",
                modifierFlags: .command,
                action: #selector(shortcutUpload(_:)),
                discoverabilityTitle: localized("shortcuts.upload_room")
            ),
            UIKeyCommand(
                input: "f",
                modifierFlags: .command,
                action: #selector(shortcutRoomMessageSearch(_:)),
                discoverabilityTitle: localized("shortcuts.search_messages")
            ),
            UIKeyCommand(
                input: "↑ ↓",
                modifierFlags: .alternate,
                action: #selector(shortcutScrollMessages(_:)),
                discoverabilityTitle: localized("shortcuts.scroll_messages")
            ),
            UIKeyCommand(
                input: UIKeyCommand.inputUpArrow,
                modifierFlags: .alternate,
                action: #selector(shortcutScrollMessages(_:))
            ),
            UIKeyCommand(
                input: UIKeyCommand.inputDownArrow,
                modifierFlags: .alternate,
                action: #selector(shortcutScrollMessages(_:))
            ),
            UIKeyCommand(
                input: "r",
                modifierFlags: .command,
                action: #selector(shortcutReplyLatest(_:)),
                discoverabilityTitle: localized("shortcuts.reply_latest")
            ),
            UIKeyCommand(
                input: "`",
                modifierFlags: [.command, .alternate],
                action: #selector(shortcutSelectServer(_:)),
                discoverabilityTitle: localized("shortcuts.server_selection")),
            UIKeyCommand(
                input: "1...9",
                modifierFlags: [.command, .alternate],
                action: #selector(shortcutSelectServer(_:)),
                discoverabilityTitle: localized("shortcuts.server_selection_numbers")
            ),
            UIKeyCommand(
                input: "n",
                modifierFlags:
                [.command, .alternate],
                action: #selector(shortcutSelectServer(_:)),
                discoverabilityTitle: localized("shortcuts.add_server")
            )
            ] + ((0...9).map({ "\($0)" })).map { (input: String) -> UIKeyCommand in
                UIKeyCommand(
                    input: input,
                    modifierFlags: .command,
                    action: #selector(shortcutSelectRoom(_:))
                )
            } + ((0...9).map({ "\($0)" })).map { (input: String) -> UIKeyCommand in
                UIKeyCommand(
                    input: input,
                    modifierFlags: [.command, .alternate],
                    action: #selector(shortcutSelectServer(_:))
                )
            } + [
                UIKeyCommand(
                    input: "t",
                    modifierFlags: .command,
                    action: #selector(shortcutChangeTheme(_:)),
                    discoverabilityTitle: localized("shortcuts.change_theme")
                ),
                UIKeyCommand(
                    input: "\r",
                    modifierFlags: [],
                    action: #selector(shortcutSend(_:)),
                    discoverabilityTitle: localized("shortcuts.send")
                ),
                UIKeyCommand(
                    input: "\r",
                    modifierFlags: .alternate,
                    action: #selector(shortcutNewline(_:)),
                    discoverabilityTitle: localized("shortcuts.new_line")
                )
        ]
    }

    @objc func shortcutFocusOnComposer(_ command: UIKeyCommand) {
        guard
            !isPresenting,
            let textView = chatViewController?.composerView.textView
        else {
            return
        }

        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
            subscriptionsViewController?.searchController?.dismiss(animated: true) { [weak self] in
                self?.chatViewController?.becomeFirstResponder()
                textView.becomeFirstResponder()
            }
        }
    }

    @objc func shortcutTogglePreferences(_ command: UIKeyCommand) {
        subscriptionsViewController?.togglePreferences()
    }

    @objc func shortcutRoomSearch(_ command: UIKeyCommand) {
        guard !isPresenting else {
            return
        }

        if subscriptionsViewController?.searchBar?.isFirstResponder ?? false {
            subscriptionsViewController?.searchController?.dismiss(animated: true, completion: nil)
        } else {
            subscriptionsViewController?.searchBar?.becomeFirstResponder()
        }
    }

    @objc func shortcutSelectServer(_ command: UIKeyCommand) {
        guard let input = command.input, !isPresenting else {
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
        guard
            let viewController = subscriptionsViewController,
            let input = command.input
        else {
            return
        }

        if input != "n" && isPresenting {
            return
        }

        switch input {
        case "n":
            viewController.toggleNewRoom()
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
        guard chatViewController?.subscription?.validated() != nil else {
            return
        }

        chatViewController?.toggleUpload()
    }

    @objc func shortcutRoomActions(_ command: UIKeyCommand) {
        guard chatViewController?.subscription?.validated() != nil else {
            return
        }

        chatViewController?.toggleActions()
    }

    @objc func shortcutRoomMessageSearch(_ command: UIKeyCommand) {
        guard chatViewController?.subscription?.validated() != nil else {
            return
        }

        chatViewController?.toggleSearchMessages()
    }

    @objc func shortcutScrollMessages(_ command: UIKeyCommand) {
        guard
            !isPresenting,
            let input = command.input,
            let offset = chatViewController?.collectionView.contentOffset,
            let maxHeight = chatViewController?.collectionView.contentSize.height,
            let collectionView = chatViewController?.collectionView
        else {
            return
        }

        let heightDelta: CGFloat = input == UIKeyCommand.inputUpArrow ? 50.0 : -50.0

        UIView.animate(withDuration: 0.1, animations: { [weak collectionView] in
            let offset = min(offset.y + heightDelta, maxHeight)
            collectionView?.contentOffset = CGPoint(x: 0, y: offset)
        })
    }

    @objc func shortcutReplyLatest(_ command: UIKeyCommand) {
        guard !isPresenting else {
            return
        }

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

    @objc func shortcutSend(_ command: UIKeyCommand) {
        guard
            !isPresenting,
            let controller = chatViewController
        else {
            return
        }

        controller.composerView(controller.composerView, didPressSendButton: controller.composerView.rightButton)
    }

    @objc func shortcutNewline(_ command: UIKeyCommand) {
        guard !isPresenting else {
            return
        }

        chatViewController?.composerView.textView.text += "\n"
    }
}
