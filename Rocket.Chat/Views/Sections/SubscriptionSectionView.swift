//
//  SubscriptionSectionView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 29/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionSectionView: UIView {

    @IBOutlet fileprivate weak var labelTitle: UILabel!

    func setTitle(_ title: String?) {
        labelTitle.text = title
    }

}
