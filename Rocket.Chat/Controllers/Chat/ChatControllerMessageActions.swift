//
//  ChatControllerMessageActions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension ChatViewController {

    func setupLongPressGestureHandler() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
        gesture.minimumPressDuration = 1
        gesture.delegate = self
        view?.addGestureRecognizer(gesture)
    }

    // MARK: Gesture handler

    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        if recognizer.state == .began {
            let touchPoint = recognizer.location(in: self.collectionView)
            if let indexPath = collectionView?.indexPathForItem(at: touchPoint) {
                if let cell = collectionView?.cellForItem(at: indexPath) as? ChatMessageCell {
                    if let message = cell.message {
                        presentActionsFor(message: message, indexPath: indexPath)
                    }
                }
            }
        }
    }

    func presentActionsFor(message: Message, indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let pinMessage = message.pinned ? localized("chat.message.actions.pin") : localized("chat.message.actions.unpin")
        alert.addAction(UIAlertAction(title: pinMessage, style: .default, handler: { (_) in
            if message.pinned {
                MessageManager.unpin(message, completion: { (response) in

                })
            } else {
                MessageManager.pin(message, completion: { (response) in

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

        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            if let cell = collectionView?.cellForItem(at: indexPath) {
                presenter.sourceView = cell
                presenter.sourceRect = cell.bounds
            } else {
                presenter.sourceView = collectionView
            }
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
