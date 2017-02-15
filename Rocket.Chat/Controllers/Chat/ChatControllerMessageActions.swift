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
            let touchPoint = recognizer.location(in: self.view)
            if let indexPath = collectionView?.indexPathForItem(at: touchPoint) {
                if messages.count > indexPath.row {
                    let message = messages[indexPath.row]
                    presentActionsFor(message: message, indexPath: indexPath)
                }
            }
        }
    }

    func presentActionsFor(message: Message, indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: localizedString("chat.message.actions.report"), style: .default, handler: { (_) in
            
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

}
