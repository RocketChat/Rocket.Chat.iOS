//
//  ChangeLanguageCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 27.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChangeLanguageCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!

    func setLanguageName(for identifier: String) {
        let locale = NSLocale(localeIdentifier: identifier)
        titleLabel.text = locale.displayName(forKey: .identifier, value: identifier)?.capitalized
    }
}
