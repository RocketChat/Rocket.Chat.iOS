//
//  SERoomAvatarView.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEAvatarView: UIView {
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
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)

        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": contentView]
            )
        )
        addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": contentView]
            )
        )
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
