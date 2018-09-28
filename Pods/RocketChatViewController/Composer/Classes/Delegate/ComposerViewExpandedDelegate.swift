//
//  ComposerViewExpandedDelegate.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

/**
 An expanded child of the ComposerViewDelegate protocol.
 This adds default implementatios for reply, autocompletion and more.
 */
public protocol ComposerViewExpandedDelegate: ComposerViewDelegate, HintsDelegate {
    func composerViewIsReplying(_ composerView: ComposerView) -> Bool
    func composerViewIsHinting(_ composerView: ComposerView) -> Bool
}

public extension ComposerViewExpandedDelegate {
    func numberOfAddons(in composerView: ComposerView, at slot: ComposerAddonSlot) -> UInt {
        return 1
    }

    func composerView(_ composerView: ComposerView, addonAt slot: ComposerAddonSlot, index: UInt) -> ComposerAddon? {
        switch slot {
        case .utility:
            return composerViewIsReplying(composerView) ? .hints : nil
        case .component:
            return composerViewIsHinting(composerView) ? .reply : nil
        }
    }

    func composerView(_ composerView: ComposerView, didUpdateAddonView view: UIView?, at slot: ComposerAddonSlot, index: UInt) {
        if let view = view as? HintsView {
            view.hintsDelegate = self
        }

        if let view = view as? ReplyView {
            view.backgroundColor = .orange
        }
    }
}
