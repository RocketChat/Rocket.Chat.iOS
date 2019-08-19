//
//  ComposerLocalizable.swift
//  DifferenceKit
//
//  Created by Matheus Cardoso on 11/20/18.
//

import Foundation

enum ComposerLocalizableKey: String {
    case textViewPlaceholder = "composer.textview.placeholder"
    case editingViewTitle = "composer.editingview.title"
    case swipeIndicatorViewTitle =  "composer.recordaudioview.swipe"

    // Accessibility

    case sendButtonLabel = "composer.sendButton.label"
    case micButtonLabel = "composer.micButton.label"
    case addButtonLabel = "composer.addButton.label"
    case redMicButtonLabel = "composer.redMicButton.label"
    case playButtonLabel = "composer.playButton.label"
    case pauseButtonLabel = "composer.pauseButton.label"
    case discardButtonLabel = "composer.discardButton.label"
    case durationLabel = "composer.duration.label"
    case swipeLabel = "composer.recordaudioview.swipe.label"
    case sliderLabelPosition = "composer.slider.position.label"
    case sliderLabelOf = "composer.slider.of.label"

    case micButtonHint = "composer.recordaudioview.micButton.hint"
}

protocol ComposerLocalizable {
    static func localized(_ key: ComposerLocalizableKey) -> String
}

extension ComposerLocalizable {
    static func localized(_ key: ComposerLocalizableKey) -> String {
        return NSLocalizedString(
            key.rawValue,
            tableName: "Localizable",
            bundle: Bundle(for: ComposerView.self),
            value: "",
            comment: ""
        )
    }
}
