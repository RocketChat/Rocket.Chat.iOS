//
//  ChatControllerEditHandler.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 06/12/2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SlackTextViewController

extension ChatViewController {
    func setupEditView() {
        editView = EditView.instantiateFromNib()
        editView.backgroundColor = textInputbar.addonContentView.backgroundColor
        editView.frame = textInputbar.addonContentView.bounds
        editView.onClose = stopEditing
        editView.alpha = 0
        textInputbar.addonContentView.addSubview(editView)
    }

    func edit(message: Message) {
        editView.alpha = 0
        editView.message.text = localized("chat.edit_mode")

        self.editedMessage = message

        show(viewToShow: editView) { (_) in
            UIView.animate(withDuration: 0.25) {
                self.textView.text = message.text
                self.editView.alpha = 1
                self.clearReplying()
            }
        }

        textView.becomeFirstResponder()

        scrollToBottom()
    }

    func clearEditing() {
        self.editView.alpha = 0
        editedMessage = nil
        textView.text = ""
    }

    func show(viewToShow: UIView, finished: @escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.textInputbar.addonContentViewHeight = 50
            self.textInputbar.layoutIfNeeded()
            viewToShow.frame = self.textInputbar.addonContentView.bounds
            self.textDidUpdate(false)
        }, completion: finished)
    }

    func hide(viewToHide: UIView) {
        UIView.animate(withDuration: 0.25, animations: ({
            viewToHide.alpha = 0
        }), completion: ({ _ in
            UIView.animate(withDuration: 0.25) {
                self.textInputbar.addonContentViewHeight = 0
                self.textInputbar.layoutIfNeeded()
                viewToHide.frame = self.textInputbar.addonContentView.bounds
                self.textDidUpdate(false)
            }
        }))
    }

    func stopEditing() {
        editView.alpha = 1
        hide(viewToHide: editView)
        clearEditing()
    }

}
