//
//  MessagesViewControllerDrafting.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension MessagesViewController {
    func startDraftMessage() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDraftMessage),
            name: UITextView.textDidChangeNotification,
            object: composerView.textView
        )

        recoverDraftMessage()
    }

    @objc func updateDraftMessage() {
        if let subscription = subscription {
            DraftMessageManager.update(draftMessage: composerView.textView.text, for: subscription)
        }
    }

    func recoverDraftMessage() {
        if let subscription = subscription {
            composerView.textView.text = DraftMessageManager.draftMessage(for: subscription)
        }
    }
}
