//
//  SEFileDetailView.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/23/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEFileDetailView: UIView, SEXibInitializable {
    @IBOutlet weak var contentView: UIView! {
        didSet {
           contentView.backgroundColor = #colorLiteral(red: 0.9370916486, green: 0.9369438291, blue: 0.9575446248, alpha: 1)
        }
    }

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeFromXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeFromXib()
    }
}
