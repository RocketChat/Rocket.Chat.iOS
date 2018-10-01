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
        return
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

        if composerViewModel.hintPrefixedWord.first == "@", let user = User.find(username: hint) {
            let cell = hintsView.dequeueReusableCell(withType: UserHintCell<AvatarView>.self)

            cell.avatarView.user = user
            cell.usernameLabel.text = hint
            cell.nameLabel.text = user.name

            return cell
        }

        let cell = hintsView.dequeueReusableCell(withType: TextHintCell.self)
        cell.prefixLabel.text = String(composerViewModel.hintPrefixedWord.first ?? " ")
        cell.valueLabel.text = String(hint)
        return cell
    }

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int) {
        if let range = composerView.textView.rangeOfNearestWordToSelection {
            let oldWord = composerView.textView.text[range]
            let newWord = (oldWord.first?.description ?? "") + composerViewModel.hints[index]
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
    }
}
