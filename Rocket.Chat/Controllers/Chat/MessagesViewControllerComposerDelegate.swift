//
//  MessagesViewControllerComposerDelegate.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RocketChatViewController

extension MessagesViewController: ComposerViewExpandedDelegate {
    func viewModel(for replyView: ReplyView) -> ReplyViewModel {
        return ReplyViewModel(nameText: "", timeText: "", text: "")
    }

    func replyViewDidHide(_ replyView: ReplyView) {
        return
    }

    func replyViewDidShow(_ replyView: ReplyView) {
        return
    }

    // MARK: Hints

    func composerView(_ composerView: ComposerView, didChangeHintPrefixedWord word: String) {
        return
    }

    func hintPrefixes(for composerView: ComposerView) -> [Character] {
        return ["/", "#", "@", ":"]
    }

    func isHinting(in composerView: ComposerView) -> Bool {
        return false
    }

    func numberOfHints(in hintsView: HintsView) -> Int {
        return 0
    }

    func hintsView(_ hintsView: HintsView, cellForHintAt index: Int) -> UITableViewCell {
        fatalError("not implemented yet")
    }

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int) {
        return
    }

    // MARK: EditingView

    func editingViewDidHide(_ editingView: EditingView) {
        return
    }

    func editingViewDidShow(_ editingView: EditingView) {
        return
    }

    // MARK: Button

    func composerView(_ composerView: ComposerView, didTapButton button: ComposerButton) {
        if button === composerView.rightButton {
            viewModel.sendTextMessage(text: composerView.textView.text)
            composerView.textView.text = ""
        }

        if button == composerView.leftButton {
            buttonUploadDidPressed()
        }
    }
}
