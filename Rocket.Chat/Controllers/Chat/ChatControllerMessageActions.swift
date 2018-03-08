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
        guard !message.temporary, message.type.actionable else { return }

        var actions: [UIAlertAction] = []

        if !message.failed {
            actions = actionsForMessage(message, view: view)
        } else {
            actions = actionsForFailedMessage(message)
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actions.forEach(alert.addAction)

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = view
            presenter.sourceRect = view.bounds
        }

        present(alert, animated: true, completion: nil)
    }

    func actionsForMessage(_ message: Message, view: UIView) -> [UIAlertAction] {
        guard let messageUser = message.user else { return [] }

        let react = UIAlertAction(title: localized("chat.message.actions.react"), style: .default, handler: { _ in
            self.react(message: message, view: view)
        })

        let pinMessage = message.pinned ? localized("chat.message.actions.unpin") : localized("chat.message.actions.pin")
        let pin = UIAlertAction(title: pinMessage, style: .default, handler: { (_) in
            if message.pinned {
                MessageManager.unpin(message, completion: { (_) in
                    // Do nothing
                })
            } else {
                MessageManager.pin(message, completion: { (_) in
                    // Do nothing
                })
            }
        })

        let report = UIAlertAction(title: localized("chat.message.actions.report"), style: .default, handler: { (_) in
            self.report(message: message)
        })

        let copy = UIAlertAction(title: localized("chat.message.actions.copy"), style: .default, handler: { (_) in
            UIPasteboard.general.string = message.text
        })

        let reply = UIAlertAction(title: localized("chat.message.actions.reply"), style: .default, handler: { [weak self] (_) in
            self?.reply(to: message)
        })

        let quote = UIAlertAction(title: localized("chat.message.actions.quote"), style: .default, handler: { [weak self] (_) in
            self?.reply(to: message, onlyQuote: true)
        })

        var actions = [react, pin, report, copy, reply, quote]

        if AuthManager.isAuthenticated()?.canBlockMessage(message) == .allowed {
            let block = UIAlertAction(title: localized("chat.message.actions.block"), style: .default, handler: { [weak self] (_) in
                DispatchQueue.main.async {
                    MessageManager.blockMessagesFrom(messageUser, completion: {
                        self?.updateSubscriptionInfo()
                    })
                }
            })

            actions.append(block)
        }

        if  AuthManager.isAuthenticated()?.canEditMessage(message) == .allowed {
            let edit = UIAlertAction(title: localized("chat.message.actions.edit"), style: .default, handler: { (_) in
                self.messageToEdit = message
                self.editText(message.text)
            })

            actions.append(edit)
        }

        if AuthManager.isAuthenticated()?.canDeleteMessage(message) == .allowed {
            let delete = UIAlertAction(title: localized("chat.message.actions.delete"), style: .destructive, handler: { _ in
                self.delete(message: message)
            })

            actions.append(delete)
        }

        return actions
    }

    func actionsForFailedMessage(_ message: Message) -> [UIAlertAction] {

        let resend = UIAlertAction(title: localized("chat.message.actions.resend"), style: .default, handler: { _ in
            guard
                let subscription = self.subscription,
                let client = API.current()?.client(MessagesClient.self)
            else {
                return
            }

            var _messageToResend: (identifier: String, text: String)? = nil

            Realm.executeOnMainThread { realm in
                guard
                    let identifier = message.identifier,
                    let failedMessage = subscription.messages.filter("identifier = %@", identifier).first
                else {
                    return
                }

                _messageToResend = (identifier: identifier, text: failedMessage.text)
                realm.delete(failedMessage)
            }

            guard let messageToResend = _messageToResend else { return }

            self.dataController.delete(msgId: messageToResend.identifier)
            client.sendMessage(text: messageToResend.text, subscription: subscription)
        })

        let resendAll = UIAlertAction(title: localized("chat.message.actions.resend_all"), style: .default, handler: { _ in
            guard
                let subscription = self.subscription,
                let client = API.current()?.client(MessagesClient.self)
            else {
                return
            }

            var messagesToResend: [(identifier: String, text: String)] = []

            Realm.executeOnMainThread { realm in
                let failedMessages = subscription.messages.filter("failed = true")
                messagesToResend = failedMessages.map { (identifier: $0.identifier ?? "", text: $0.text) }
                realm.delete(failedMessages)
            }

            messagesToResend.forEach {
                self.dataController.delete(msgId: $0.identifier)
                client.sendMessage(text: $0.text, subscription: subscription)
            }
        })

        let discard = UIAlertAction(title: localized("chat.message.actions.delete"), style: .destructive, handler: { _ in
            self.discard(message: message)
        })

        return [resend, resendAll, discard]
    }

    // MARK: Actions

    fileprivate func react(message: Message, view: UIView) {
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
            UserReviewManager.shared.requestReview()
        }

        controller.customEmojis = CustomEmoji.emojis()

        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            self.present(controller, animated: true)
        }
    }

    fileprivate func delete(message: Message) {
        Ask(key: "chat.message.actions.delete.confirm", buttons: [
            (title: localized("global.no"), handler: nil),
            (title: localized("chat.message.actions.delete.confirm.yes"), handler: { _ in
                API.current()?.client(MessagesClient.self).deleteMessage(message, asUser: false)
            })
        ], deleteOption: 1).present()
    }

    fileprivate func discard(message: Message) {
        Ask(key: "chat.message.actions.discard.confirm", buttons: [
            (title: localized("global.no"), handler: nil),
            (title: localized("chat.message.actions.discard.confirm.yes"), handler: { [weak self] _ in
                guard let msgId = message.identifier else { return }
                self?.deleteMessage(msgId: msgId)
            })
        ], deleteOption: 1).present()
    }

    fileprivate func report(message: Message) {
        MessageManager.report(message) { (_) in
            Alert(
                key: "chat.message.report.success.title"
            ).present()
        }
    }
}
