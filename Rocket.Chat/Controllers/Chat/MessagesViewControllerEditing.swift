//
//  MessagesViewControllerEditing.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RocketChatViewController

extension MessagesViewController {
    var editingView: EditingView? {
        return composerView.componentStackView.arrangedSubviews.first {
            $0 as? EditingView != nil
        } as? EditingView
    }

    func stopEditingMessage() {
        composerViewModel.messageToEdit = nil
        composerView.textView.text = ""
    }

    func editMessage(_ message: Message) {
        composerViewModel.messageToEdit = message
        composerView.textView.text = message.text
        composerView.textView.becomeFirstResponder()

        UIView.animate(withDuration: 0.2) {
            self.editingView?.isHidden = false
            self.composerView.layoutIfNeeded()
        }
    }

    func commitMessageEdit() {
        guard
            let client = API.current()?.client(MessagesClient.self),
            let message = composerViewModel.messageToEdit,
            let text = composerView.textView.text
        else {
            return Alert.defaultError.present()
        }

        UIView.animate(withDuration: 0.2) {
            self.editingView?.isHidden = true
            self.composerView.layoutIfNeeded()
        }

        client.updateMessage(message, text: text)
    }
}
