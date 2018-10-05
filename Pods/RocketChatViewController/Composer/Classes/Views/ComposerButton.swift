//
//  ComposerButton.swift
//  RocketChatViewController
//
//  Created by Matheus Cardoso on 9/28/18.
//

import UIKit

public class ComposerButton: UIButton {
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: isHidden ? 0 : 24, height: 24)
    }

    public func hide() {
        isHidden = true
        isOpaque = false
        alpha = 0
        invalidateIntrinsicContentSize()
    }

    public func show() {
        isHidden = false
        isOpaque = false
        alpha = 1
        invalidateIntrinsicContentSize()
    }
}
