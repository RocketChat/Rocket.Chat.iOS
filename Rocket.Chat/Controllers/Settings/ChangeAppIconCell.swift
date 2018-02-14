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

    func setIcon(name: String) {
        iconImageView.image = UIImage(named: name)
    }
}
