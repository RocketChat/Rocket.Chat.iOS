//
//  MessagesViewControllerSending.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension MessagesViewController {
    func sendButtonPressed() {
        if composerViewModel.messageToEdit != nil {
            commitMessageEdit()
        } else {
            viewModel.sendTextMessage(text: composerView.textView.text + composerViewModel.replyString)
        }

        composerView.textView.text = ""

        stopReplying()
    }
}
