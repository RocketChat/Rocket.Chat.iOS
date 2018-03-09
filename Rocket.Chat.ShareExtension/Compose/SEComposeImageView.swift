//
//  SEComposeImageView.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeImageView: UIView, SEXibInitializable {
    @IBOutlet var contentView: UIView! {
        didSet {
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = 4.0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeFromXib()
    }
}
