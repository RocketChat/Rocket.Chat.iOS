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
        viewModel.hints = []
        viewModel.hintPrefixedWord = word

        guard
            let realm = Realm.current,
            let prefix = viewModel.hintPrefixedWord.first
        else {
            return
        }

        let word = String(word.dropFirst())

        if prefix == "@" {
            viewModel.hints = User.search(usernameContaining: word, preference: []).map { $0.0 }

            if "here".contains(word) || word.count == 0 {
                viewModel.hints.append("here")
            }

            if "all".contains(word) || word.count == 0 {
                viewModel.hints.append("all")
            }
        } else if prefix == "#" {
            let filter = "auth != nil && (privateType == 'c' || privateType == 'p')\(word.isEmpty ? "" : "&& name BEGINSWITH[c] %@")"

            let channels = realm.objects(Subscription.self).filter(filter, word)

            for channel in channels {
                viewModel.hints.append(channel.name)
            }

        } else if prefix == "/" {
            let commands: Results<Command>
            if word.count > 0 {
                commands = realm.objects(Command.self).filter("command BEGINSWITH[c] %@", word)
            } else {
                commands = realm.objects(Command.self)
            }

            commands.forEach {
                viewModel.hints.append($0.command)
            }
        } else if prefix == ":" {
            let emojis = EmojiSearcher.standard.search(shortname: word.lowercased(), custom: CustomEmoji.emojis())

            emojis.forEach {
                viewModel.hints.append($0.suggestion)
            }
        }
    }

    func hintPrefixes(for composerView: ComposerView) -> [Character] {
        return ["/", "#", "@", ":"]
    }

    func isHinting(in composerView: ComposerView) -> Bool {
        return viewModel.hints.count > 0
    }

    func numberOfHints(in hintsView: HintsView) -> Int {
        return viewModel.hints.count
    }

    func hintsView(_ hintsView: HintsView, cellForHintAt index: Int) -> UITableViewCell {
        let hint = viewModel.hints[index]
        let cell = hintsView.dequeueReusableCell(withType: TextHintCell.self)
        cell?.prefixLabel.text = String(viewModel.hintPrefixedWord.first ?? " ")
        cell?.valueLabel.text = String(hint)
        return cell ?? UITableViewCell()
    }

    func hintsView(_ hintsView: HintsView, didSelectHintAt index: Int) {
        if let range = composerView.textView.rangeOfNearestWordToSelection {
            let oldWord = composerView.textView.text[range]
            let newWord = (oldWord.first?.description ?? "") + viewModel.hints[index]
            composerView.textView.text = composerView.textView.text.replacingCharacters(in: range, with: newWord)
        }

        viewModel.hints = []

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
