//
//  MessagesViewControllerComposerDelegate.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RocketChatViewController
import RealmSwift

extension MessagesViewController: ComposerViewExpandedDelegate {
    func viewModel(for replyView: ReplyView) -> ReplyViewModel {
        return ReplyViewModel(nameText: "", timeText: "", text: "")
    }

    func replyViewDidHide(_ replyView: ReplyView) {
        composerViewModel.replyString = ""
    }

    func replyViewDidShow(_ replyView: ReplyView) {
        return
    }

    // MARK: Hints

    func composerView(_ composerView: ComposerView, didChangeHintPrefixedWord word: String) {
        composerViewModel.didChangeHintPrefixedWord(word: word)
    }

    func hintPrefixes(for composerView: ComposerView) -> [Character] {
        return composerViewModel.hintPrefixes
    }

    func isHinting(in composerView: ComposerView) -> Bool {
        return composerViewModel.hints.count > 0
    }

    func numberOfHints(in hintsView: HintsView) -> Int {
        return composerViewModel.hints.count
    }

    func hintsView(_ hintsView: HintsView, cellForHintAt index: Int) -> UITableViewCell {
        let hint = composerViewModel.hints[index]

        switch hint {
        case .user(let user):
            let cell = hintsView.dequeueReusableCell(withType: UserHintCell<AvatarView>.self)
            cell.avatarView.username = user.username
            cell.usernameLabel.text = user.username
            cell.nameLabel.text = user.name
            return cell

        case .emoji(let emoji, _):
            let cell = hintsView.dequeueReusableCell(withType: TextHintCell<EmojiView>.self)
            cell.prefixView.setEmoji(emoji)
            cell.valueLabel.text = emoji.shortname
            return cell

        case .command(let command):
            let cell = hintsView.dequeueReusableCell(withType: TextHintCell<UILabel>.self)
            cell.prefixView.text = "/"
            cell.valueLabel.text = command.command
            return cell

        case .room(let room):
            let cell = hintsView.dequeueReusableCell(withType: TextHintCell<UILabel>.self)
            cell.prefixView.text = "#"
            cell.valueLabel.text = room.name
            return cell

        case .userGroup(let userGroup):
            let cell = hintsView.dequeueReusableCell(withType: TextHintCell<UILabel>.self)
            cell.prefixView.text = "@"
            cell.valueLabel.text = userGroup
            return cell
        }
    }

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int) {
        if let range = composerView.textView.rangeOfNearestWordToSelection {
            let oldWord = composerView.textView.text[range]
            let newWord = (oldWord.first?.description ?? "") + composerViewModel.hints[index].suggestion
            composerView.textView.text = composerView.textView.text.replacingCharacters(in: range, with: newWord)
        }

        composerViewModel.hints = []

        UIView.animate(withDuration: 0.2) {
            hintsView.reloadData()
            hintsView.invalidateIntrinsicContentSize()
            hintsView.layoutIfNeeded()
        }
    }

    // MARK: EditingView

    func editingViewDidHide(_ editingView: EditingView) {
        stopEditingMessage()

        UIView.animate(withDuration: 0.2) {
            self.composerView.leftButton.show()
        }
    }

    func editingViewDidShow(_ editingView: EditingView) {
        UIView.animate(withDuration: 0.2) {
            self.composerView.leftButton.hide()
        }
    }

    // MARK: Button

    func composerView(_ composerView: ComposerView, didTapButton button: ComposerButton) {
        if button === composerView.rightButton {
            if composerViewModel.messageToEdit != nil {
                commitMessageEdit()
            } else {
                viewModel.sendTextMessage(text: composerView.textView.text + composerViewModel.replyString)
            }

            composerView.textView.text = ""

            stopReplying()
        }

        if button == composerView.leftButton {
            buttonUploadDidPressed()
        }

        if button == composerView.leftButton {
            buttonUploadDidPressed()
        }
    }
}
