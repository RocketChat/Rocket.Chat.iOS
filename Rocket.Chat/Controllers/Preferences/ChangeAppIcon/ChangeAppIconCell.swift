//
//  ChangeAppIconCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 08.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChangeAppIconCell: UICollectionViewCell {

    @IBOutlet private weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.isAccessibilityElement = true
        }
    }
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var checkImageViewBackground: UIView!

    func setIcon(name: (String, String), selected: Bool) {
        iconImageView.image = UIImage(named: name.0)
        iconImageView.accessibilityLabel = VOLocalizedString(name.1)

        if selected {
            iconImageView.layer.borderColor = UIColor.RCBlue().cgColor
            iconImageView.layer.borderWidth = 3
            iconImageView.accessibilityTraits = .selected

            checkImageView.image = checkImageView.image?.imageWithTint(UIColor.RCBlue())
            checkImageView.isHidden = false
            checkImageViewBackground.isHidden = false
        } else {
            iconImageView.layer.borderColor = UIColor.RCLightGray().cgColor
            iconImageView.layer.borderWidth = 1
            iconImageView.accessibilityTraits = .none

            checkImageView.isHidden = true
            checkImageViewBackground.isHidden = true
        }
    }

}
