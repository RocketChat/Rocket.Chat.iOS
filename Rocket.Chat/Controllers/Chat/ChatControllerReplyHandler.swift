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
    func setupReplyView() {
        replyView = ReplyView.instantiateFromNib()
        replyView.backgroundColor = textInputbar.addonContentView.backgroundColor
        replyView.frame = textInputbar.addonContentView.bounds
        replyView.onClose = stopReplying
        replyView.alpha = 0
        textInputbar.addonContentView.addSubview(replyView)
    }

    func reply(to message: Message, onlyQuote: Bool = false) {
        replyView.alpha = 0
        replyView.username.text = message.user?.username
        replyView.message.text = message.text

        show(viewToShow: replyView) { (_) in
            UIView.animate(withDuration: 0.25) {
                self.replyView.alpha = 1
                self.clearEditing()
            }
        }
        
        textView.becomeFirstResponder()

        replyString = (onlyQuote ? message.quoteString : message.replyString) ?? ""

        scrollToBottom()
    }

    func clearReplying() {
        self.replyView.alpha = 0
        replyString = ""
    }

    func stopReplying() {
        replyView.alpha = 1

        hide(viewToHide: replyView)

        clearReplying()
    }

}
