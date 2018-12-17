//
//  ComposerViewDelegate.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

/**
 The delegate of an ComposerView object must adopt the ComposerViewDelegate protocol.
 Optional methods of the protocol allow the delegate to configure composer addons and perform actions.
 */
public protocol ComposerViewDelegate: class {
    /**
     Asks the how many addons to place in the composer.
     */
    func numberOfAddons(in composerView: ComposerView, at slot: ComposerAddonSlot) -> UInt

    /**
     Asks the delegate which addon to place in the addon index slot.
     */
    func composerView(_ composerView: ComposerView, addonAt slot: ComposerAddonSlot, index: UInt) -> ComposerAddon?

    /**
     Asks the delegate if the composer view should process the pressing of the return button.
     */
    func composerViewShouldReturn(_ composerView: ComposerView) -> Bool

    /**
     Tells the delegate that the text selection changed in the specified composer view's text view.
     */
    func composerViewDidChangeSelection(_ composerView: ComposerView)

    /**
     Tells the delegate the current addon view has been updated or changed.
     */
    func composerView(_ composerView: ComposerView, didUpdateAddonView view: UIView?, at slot: ComposerAddonSlot, index: UInt)

    /**
     Tells the delegate the button in the slot has been tapped.
     */
    func composerView(_ composerView: ComposerView, didTapButton button: ComposerButton)
}

public extension ComposerViewDelegate {
    func numberOfAddons(in composerView: ComposerView, at slot: ComposerAddonSlot) -> UInt {
        return 0
    }

    func composerView(_ composerView: ComposerView, addonAt slot: ComposerAddonSlot, index: UInt) -> ComposerAddon? {
        return nil
    }

    func composerViewShouldReturn(_ composerView: ComposerView) -> Bool {
        return true
    }

    func composerViewDidChangeSelection(_ composerView: ComposerView) { }
    func composerView(_ composerView: ComposerView, didUpdateAddonView view: UIView?, at slot: ComposerAddonSlot, index: UInt) { }
    func composerView(_ composerView: ComposerView, didTapButton button: ComposerButton) { }
}
