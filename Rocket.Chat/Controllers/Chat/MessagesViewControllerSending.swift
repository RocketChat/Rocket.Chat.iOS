//
//  MessagesViewControllerSending.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RocketChatViewController

extension MessagesViewController {

    func composerView(_ composerView: ComposerView, didPressSendButton button: UIButton) {
        if composerViewModel.messageToEdit != nil {
            commitMessageEdit()
        } else {
            viewModel.sendTextMessage(
                text: composerView.textView.text + composerViewModel.quoteString,
                replyThreadIdentifier: composerViewModel.replyMessageIdentifier
            )
        }

        composerView.textView.text = ""

        stopReplying()
        updateDraftMessage()
    }

}
