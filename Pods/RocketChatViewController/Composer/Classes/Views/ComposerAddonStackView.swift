//
//  AddonStackView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public class ComposerAddonStackView: UIStackView {
    private var nextIntrinsicContentSize = CGSize.zero

    public override var intrinsicContentSize: CGSize {
        return arrangedSubviews.count > 0 ? super.intrinsicContentSize : CGSize(width: super.intrinsicContentSize.width, height: 0)
    }
}
