//
//  SEXibInitializable.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol SEXibInitializable {
    var contentView: UIView! { get set }
    func initializeFromXib()
}

extension SEXibInitializable where Self: UIView {
    func initializeFromXib() {
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
}
