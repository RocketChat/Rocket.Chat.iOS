//
//  ChatControllerReplyHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SlackTextViewController

extension ChatViewController {

    func quoteStringFor(_ message: Message) -> String? {
        guard
            let subscription = subscription,
            let url = subscription.auth?.baseURL(),
            let id = message.identifier
        else {
            return nil
        }

        let path: String

        switch subscription.type {
        case .channel:
            path = "channel"
        case .group:
            path = "group"
        case .directMessage:
            path = "direct"
        }

        return " [ ](\(url)/\(path)/\(subscription.name)?msg=\(id))"
    }

    func replyStringFor(_ message: Message) -> String? {
        guard
            let subscription = subscription,
            let quoteString = quoteStringFor(message)
        else {
            return nil
        }

        guard
            subscription.type != .directMessage,
            let username = message.user?.username,
            username != AuthManager.currentUser()?.username
        else {
            return quoteString
        }

        return " @\(username)\(quoteString)"
    }

    func setupReplyView() {
        replyView = ReplyView.instantiateFromNib()
        replyView.backgroundColor = textInputbar.addonContentView.backgroundColor
        replyView.frame = textInputbar.addonContentView.bounds
        replyView.onClose = stopReplying

        textInputbar.addonContentView.addSubview(replyView)
    }

    func reply(to message: Message, onlyQuote: Bool = false) {
        replyView.alpha = 0
        replyView.username.text = message.user?.username
        replyView.message.text = message.text

        UIView.animate(withDuration: 0.25, animations: ({
            self.textInputbar.addonContentViewHeight = 50
            self.textInputbar.layoutIfNeeded()
            self.replyView.frame = self.textInputbar.addonContentView.bounds
            self.textDidUpdate(false)
        }), completion: ({ _ in
            UIView.animate(withDuration: 0.25) {
                self.replyView.alpha = 1
            }
        }))

        textView.becomeFirstResponder()

        replyString = (onlyQuote ? quoteStringFor(message) : replyStringFor(message)) ?? ""

        scrollToBottom()
    }

    func stopReplying() {
        replyView.alpha = 1

        UIView.animate(withDuration: 0.25, animations: ({
            self.replyView.alpha = 0
        }), completion: ({ _ in
            UIView.animate(withDuration: 0.25) {
                self.textInputbar.addonContentViewHeight = 0
                self.textInputbar.layoutIfNeeded()
                self.replyView.frame = self.textInputbar.addonContentView.bounds
                self.textDidUpdate(false)
            }
        }))

        replyString = ""
    }

}
