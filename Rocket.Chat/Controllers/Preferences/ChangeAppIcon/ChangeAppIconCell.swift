//
//  ChangeAppIconCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 08.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChangeAppIconCell: UICollectionViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var checkImageView: UIImageView!
    @IBOutlet private weak var checkImageViewBackground: UIView!

    func setIcon(name: String, selected: Bool) {
        iconImageView.image = UIImage(named: name)

        if selected {
            iconImageView.layer.borderColor = UIColor.RCBlue().cgColor
            iconImageView.layer.borderWidth = 3

            checkImageView.image = checkImageView.image?.imageWithTint(UIColor.RCBlue())
            checkImageView.isHidden = false
            checkImageViewBackground.isHidden = false
        } else {
            iconImageView.layer.borderColor = UIColor.RCLightGray().cgColor
            iconImageView.layer.borderWidth = 1

            checkImageView.isHidden = true
            checkImageViewBackground.isHidden = true
        }
    }

}
