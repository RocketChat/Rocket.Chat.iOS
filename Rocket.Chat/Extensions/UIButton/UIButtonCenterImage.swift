//
//  UIButtonCenterImage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 7/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIButton {
    func centerImageHorizontally() {
        guard
            let imageViewWidth = imageView?.frame.width
        else {
            return
        }

        imageEdgeInsets = UIEdgeInsets(
            top: imageEdgeInsets.top,
            left: frame.width/2 - imageViewWidth/2 - 1,
            bottom: imageEdgeInsets.bottom,
            right: imageEdgeInsets.right
        )

        titleEdgeInsets = UIEdgeInsets(
            top: titleEdgeInsets.top,
            left: -imageViewWidth - 1,
            bottom: titleEdgeInsets.bottom,
            right: titleEdgeInsets.right
        )
    }
}
