//
//  ChatControllerMessageActions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController {

    fileprivate func quoteStringFor(_ message: Message) -> String? {
        guard let url = subscription.auth?.baseURL() else { return nil }
        guard let id = message.identifier else { return nil }

        let path: String

        switch subscription.type {
        case .channel:
            path = "channel"
        case .group:
            path = "group"
        case .directMessage:
            path = "direct"
        }

        return "[ ](\(url)/\(path)/\(subscription.name)?msg=\(id))"
    }

    func presentActionsFor(_ message: Message, view: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

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
            guard let quoteString = self?.quoteStringFor(message) else { return }
            guard let text = self?.textView.text else { return }

            self?.textView.text = "\(text) \(quoteString)"
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
