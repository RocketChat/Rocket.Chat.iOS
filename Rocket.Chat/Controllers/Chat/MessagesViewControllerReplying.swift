//
//  ChatControllerReplyHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

extension MessagesViewController {
    var replyView: ReplyView? {
        return composerView.componentStackView.arrangedSubviews.first {
            $0 as? ReplyView != nil
        } as? ReplyView
    }

    func reply(to message: Message, onlyQuote: Bool = false) {
        replyView?.nameLabel.text = message.user?.displayName()

        let text = Emojione.transform(string: message.textNormalized())
        replyView?.textLabel.attributedText = NSMutableAttributedString(string: text)
            .transformMarkdown(with: view.theme)

        if let updatedAt = message.updatedAt {
            replyView?.timeLabel.text = RCDateFormatter.time(updatedAt)
        }

        UIView.animate(withDuration: 0.25) {
            self.replyView?.isHidden = false
            self.composerView.layoutIfNeeded()
        }

        composerView.textView.becomeFirstResponder()

        if onlyQuote {
            composerViewModel.replyMessageIdentifier = ""
            composerViewModel.quoteString = message.quoteString ?? ""
        } else {
            composerViewModel.replyMessageIdentifier = message.identifier ?? ""
            composerViewModel.quoteString = ""
        }
    }

    func stopReplying() {
        UIView.animate(withDuration: 0.25) {
            self.replyView?.isHidden = true
            self.composerView.layoutIfNeeded()
        }

        composerViewModel.replyMessageIdentifier = ""
        composerViewModel.quoteString = ""
    }
}
