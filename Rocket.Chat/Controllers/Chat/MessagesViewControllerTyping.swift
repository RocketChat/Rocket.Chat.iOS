//
//  MessagesViewControllerTyping.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 21/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension MessagesViewController {
    func startTypingHandler() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTyping),
            name: UITextView.textDidChangeNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEndedTyping),
            name: UITextView.textDidEndEditingNotification,
            object: nil
        )
    }

    @objc func handleTyping() {
        viewSubscriptionModel.isTyping = composerView.textView.text != ""
    }

    @objc func handleEndedTyping() {
        viewSubscriptionModel.isTyping = false
    }
}
