//
//  ThemePreferenceCell.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ThemePreferenceCell: UITableViewCell {

    static let identifier = "ThemePreferenceCell"
    static let cellHeight: CGFloat = 78

    let borderWidth: CGFloat = 1.0
    let borderColor = #colorLiteral(red: 0.4980838895, green: 0.4951269031, blue: 0.5003594756, alpha: 0.1950449486).cgColor

    var cellTheme: Theme? {
        didSet {
            setViewsForTheme()
        }
    }

    func setViewsForTheme() {
        baseColorView.backgroundColor = cellTheme?.backgroundColor
        auxiliaryColorView.backgroundColor = cellTheme?.bodyText
        tintColor = cellTheme?.tintColor

        if ThemeManager.theme == cellTheme {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }

    @IBOutlet weak var baseColorView: UIView! {
        didSet {
            baseColorView.layer.cornerRadius = 4
            baseColorView.layer.masksToBounds = true
            baseColorView.layer.borderWidth = borderWidth
            baseColorView.layer.borderColor = borderColor
        }
    }

    @IBOutlet weak var auxiliaryColorView: UIView! {
        didSet {
            auxiliaryColorView.layer.cornerRadius = 4
            auxiliaryColorView.layer.masksToBounds = true
            auxiliaryColorView.layer.borderWidth = borderWidth
            auxiliaryColorView.layer.borderColor = borderColor
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
}

extension ThemePreferenceCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setViewsForTheme()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        setViewsForTheme()
    }
}

// MARK: Themeable

extension ThemePreferenceCell {
    override func applyTheme() {
        super.applyTheme()
        setViewsForTheme()
    }
}
