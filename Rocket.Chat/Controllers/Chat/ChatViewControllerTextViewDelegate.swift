//
//  ChatViewControllerTextViewDelegate.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension ChatViewController {

    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard
            let currentText = textView.text,
            let stringRange = Range(range, in: currentText)
        else {
            return true
        }

        let text = currentText.replacingCharacters(in: stringRange, with: text)
        return MessageTextValidator.isSizeValid(text: text)
    }

}
