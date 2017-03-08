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
        collectionView?.addGestureRecognizer(gesture)
    }

    // MARK: Gesture handler

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

        alert.addAction(UIAlertAction(title: localizedString("chat.message.actions.report"), style: .default, handler: { (_) in
            self.report(message: message)
        }))

        alert.addAction(UIAlertAction(title: localizedString("chat.message.actions.block"), style: .default, handler: { [weak self] (_) in
            guard let user = message.user else { return }

            DispatchQueue.main.async {
                MessageManager.blockMessagesFrom(user, completion: {
                    self?.updateSubscriptionInfo()
                })
            }
        }))

        alert.addAction(UIAlertAction(title: localizedString("chat.message.actions.copy"), style: .default, handler: { (_) in
            UIPasteboard.general.string = message.text
        }))

        alert.addAction(UIAlertAction(title: localizedString("global.cancel"), style: .cancel, handler: nil))

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
                title: localizedString("chat.message.report.success.title"),
                message: localizedString("chat.message.report.success.message"),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: localizedString("global.ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}
