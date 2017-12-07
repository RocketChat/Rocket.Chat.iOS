//
//  VOLocalized.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension UIView {
    var localizedAccessibilityLabel: String? {
        guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
        return VOLocalizedString("\(accessibilityIdentifier).label")
    }

    var localizedAccessibilityValue: String? {
        guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
        return VOLocalizedString("\(accessibilityIdentifier).value")
    }

    var localizedAccessibilityHint: String? {
        guard let accessibilityIdentifier = accessibilityIdentifier else { return nil }
        return VOLocalizedString("\(accessibilityIdentifier).hint")
    }
}

func VOLocalizedString(_ key: String) -> String? {
    let string = NSLocalizedString(key, tableName: "VoiceOver", bundle: Bundle.main, value: "", comment: "")
    return string != "" ? string : nil
}
