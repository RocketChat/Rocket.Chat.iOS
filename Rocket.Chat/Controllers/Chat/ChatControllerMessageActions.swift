//
//  ChatControllerMessageActions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension ChatViewController {
    func presentActionsFor(_ message: Message, view: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: localized("chat.message.actions.react"), style: .default, handler: { _ in
            self.view.endEditing(true)

            let controller = EmojiPickerController()
            controller.modalPresentationStyle = .popover
            controller.preferredContentSize = CGSize(width: 600.0, height: 400.0)

            if let presenter = controller.popoverPresentationController {
                presenter.sourceView = view
                presenter.sourceRect = view.bounds
            }

            controller.emojiPicked = { emoji in
                MessageManager.react(message, emoji: emoji, completion: { _ in })
            }

            controller.customEmojis = CustomEmoji.emojis()

            if UIDevice.current.userInterfaceIdiom == .phone {
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                self.present(controller, animated: true)
            }
        }))

        let pinMessage = message.pinned ? localized("chat.message.actions.unpin") : localized("chat.message.actions.pin")
        alert.addAction(UIAlertAction(title: pinMessage, style: .default, handler: { (_) in
            if message.pinned {
                MessageManager.unpin(message, completion: { (_) in
                    // Do nothing
                })
            } else {
                MessageManager.pin(message, completion: { (_) in
                    // Do nothing
                })
            }
        }))

        alert.addAction(UIAlertAction(title: localized("chat.message.actions.report"), style: .default, handler: { (_) in
            self.report(message: message)
        }))

        alert.addAction(UIAlertAction(title: localized("chat.message.actions.block"), style: .default, handler: { [weak self] (_) in
            guard let user = message.user else { return }

            DispatchQueue.main.async {
                MessageManager.blockMessagesFrom(user, completion: {
                    self?.updateSubscriptionInfo()
                })
            }
        }))

        alert.addAction(UIAlertAction(title: localized("chat.message.actions.copy"), style: .default, handler: { (_) in
            UIPasteboard.general.string = message.text
        }))

        alert.addAction(UIAlertAction(title: localized("chat.message.actions.quote"), style: .default, handler: { [weak self] (_) in
            self?.reply(to: message, onlyQuote: true)
        }))

        alert.addAction(UIAlertAction(title: localized("chat.message.actions.reply"), style: .default, handler: { [weak self] (_) in
            self?.reply(to: message)
        }))

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = view
            presenter.sourceRect = view.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    // MARK: Actions

    fileprivate func report(message: Message) {
        MessageManager.report(message) { (_) in
            let alert = UIAlertController(
                title: localized("chat.message.report.success.title"),
                message: localized("chat.message.report.success.message"),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
