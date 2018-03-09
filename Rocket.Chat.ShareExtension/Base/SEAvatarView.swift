//
//  SERoomAvatarView.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEAvatarView: UIView, SEXibInitializable {
    @IBOutlet var contentView: UIView! {
        didSet {
            contentView.layer.masksToBounds = true
            contentView.layer.cornerRadius = 4.0
        }
    }

    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    var name: String = "" {
        didSet {
            if let first = name.first {
                initialsLabel.text = "\(first)".uppercased()
                initialsLabel.backgroundColor = UIColor.forName(name)
            }
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

    func prepareForReuse() {
        imageView.image = nil
        initialsLabel.backgroundColor = UIColor.clear
        initialsLabel.text = ""
        initialsLabel.isHidden = false
        imageView.isHidden = true
    }

    func setImageUrl(_ url: String) {
        imageView.sd_setImage(with: URL(string: url)) { [weak self] image, _, _, _ in
            self?.initialsLabel.isHidden = image != nil
            self?.imageView.isHidden = image == nil
        }
    }
}
