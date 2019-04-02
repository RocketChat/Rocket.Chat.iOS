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
