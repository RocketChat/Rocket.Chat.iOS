//
//  MessagesViewControllerComposerDelegate.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RocketChatViewController

extension MessagesViewController: ComposerViewExpandedDelegate {
    func replyViewDidHide(_ replyView: ReplyView) {
        composerViewModel.replyMessageIdentifier = ""
    }

    func replyViewDidShow(_ replyView: ReplyView) {
        return
    }

    // MARK: Audio

    func composerView(_ composerView: ComposerView, didFinishRecordingAudio url: URL) {
        upload(audioWithURL: url)

        if let subscriptionType = viewModel.subscription?.type {
            AnalyticsManager.log(
                event: Event.audioMessage(subscriptionType: subscriptionType.rawValue
            ))
        }
    }

    func composerView(_ composerView: ComposerView, didConfigureOverlayView view: OverlayView) {
        ThemeManager.addObserver(view)
    }

    // MARK: Hints

    func composerView(_ composerView: ComposerView, didChangeHintPrefixedWord word: String) {

        // Don't generate hints if it is a slash command and not the first word
        if word.first == "/" && composerView.textView.text != word {
            return
        }

        composerViewModel.didChangeHintPrefixedWord(word: word)

        if composerViewModel.hints.count > 0 {
            parent?.startDimming()
        } else {
            parent?.stopDimming()
        }
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
            let cell = hintsView.dequeueReusableCell(withType: UserHintAvatarViewCell.self)
            cell.avatarView.username = user.username
            cell.usernameLabel.text = user.username
            cell.nameLabel.text = user.name
            return cell

        case .emoji(let emoji, _):
            let cell = hintsView.dequeueReusableCell(withType: TextHintEmojiViewCell.self)
            cell.prefixView.setEmoji(emoji)
            cell.valueLabel.text = emoji.shortname

            if cell.valueLabel.text?.first != ":" {
                cell.valueLabel.text = ":\(cell.valueLabel.text ?? ""):"
            }

            return cell

        case .command(let command):
            let cell = hintsView.dequeueReusableCell(withType: TextHintLabelCell.self)
            cell.prefixView.text = "/"
            cell.valueLabel.text = command.command
            return cell

        case .room(let room):
            let cell = hintsView.dequeueReusableCell(withType: TextHintLabelCell.self)
            cell.prefixView.text = "#"
            cell.valueLabel.text = room.name
            return cell

        case .userGroup(let userGroup):
            let cell = hintsView.dequeueReusableCell(withType: TextHintLabelCell.self)
            cell.prefixView.text = ""
            cell.valueLabel.text = userGroup
            return cell
        }
    }

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int) {
        if let range = composerView.textView.rangeOfNearestWordToSelection {
            let oldWord = composerView.textView.text[range]
            let newWord = (oldWord.first?.description ?? "") + composerViewModel.hints[index].suggestion + " "
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

    // MARK: Return

    func composerViewShouldReturn(_ composerView: ComposerView) -> Bool {
        return true
    }
}
