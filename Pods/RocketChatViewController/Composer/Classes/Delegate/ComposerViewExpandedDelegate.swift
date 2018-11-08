//
//  ComposerViewExpandedDelegate.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

private extension ComposerView {
    var hintsView: HintsView? {
        return utilityStackView.subviews.first(where: { $0 as? HintsView != nil }) as? HintsView
    }

    var replyView: ReplyView? {
        return componentStackView.subviews.first(where: { $0 as? ReplyView != nil }) as? ReplyView
    }

    var editingView: EditingView? {
        return componentStackView.subviews.first(where: { $0 as? EditingView != nil }) as? EditingView
    }
}

/**
 An expanded child of the ComposerViewDelegate protocol.
 This adds default implementatios for reply, autocompletion and more.
 */
public protocol ComposerViewExpandedDelegate: ComposerViewDelegate, HintsViewDelegate, ReplyViewDelegate, EditingViewDelegate {
    func hintPrefixes(for composerView: ComposerView) -> [Character]
    func isHinting(in composerView: ComposerView) -> Bool

    func composerView(_ composerView: ComposerView, didChangeHintPrefixedWord word: String)
}

public extension ComposerViewExpandedDelegate {
    func composerViewDidChangeSelection(_ composerView: ComposerView) {
        func didChangeHintPrefixedWord(_ word: String) {
            self.composerView(composerView, didChangeHintPrefixedWord: word)

            guard let hintsView = composerView.hintsView else {
                return
            }

            UIView.animate(withDuration: 0.2) {
                hintsView.reloadData()
                hintsView.invalidateIntrinsicContentSize()
                hintsView.layoutIfNeeded()
            }
        }

        if let range = composerView.textView.rangeOfNearestWordToSelection {
            let word = String(composerView.textView.text[range])

            if let char = word.first, hintPrefixes(for: composerView).contains(char) {
                didChangeHintPrefixedWord(word)
            } else {
                didChangeHintPrefixedWord("")
            }

            return
        }

        didChangeHintPrefixedWord("")
    }

    func composerView(_ composerView: ComposerView, didTapButton button: ComposerButton) {
        if button === composerView.leftButton {
            UIView.animate(withDuration: 0.2) {
                composerView.editingView?.isHidden = false
                composerView.layoutIfNeeded()
            }
        }

        if button === composerView.rightButton {
            UIView.animate(withDuration: 0.2) {
                composerView.textView.text = ""
                composerView.replyView?.isHidden = true
                composerView.editingView?.isHidden = true
                composerView.layoutIfNeeded()
            }
        }
    }

    // MARK: Addons

    func numberOfAddons(in composerView: ComposerView, at slot: ComposerAddonSlot) -> UInt {
        switch slot {
        case .utility:
            return 1
        case .component:
            return 2
        }
    }

    func composerView(_ composerView: ComposerView, addonAt slot: ComposerAddonSlot, index: UInt) -> ComposerAddon? {
        switch slot {
        case .utility:
            return .hints
        case .component:
            switch index {
            case 0:
                return .reply
            case 1:
                return .editing
            default:
                return nil
            }
        }
    }

    func composerView(_ composerView: ComposerView, didUpdateAddonView view: UIView?, at slot: ComposerAddonSlot, index: UInt) {
        if let view = view as? HintsView {
            view.hintsDelegate = self
        }

        if let view = view as? ReplyView {
            view.delegate = self
        }

        if let view = view as? EditingView {
            view.delegate = self
        }
    }
}
