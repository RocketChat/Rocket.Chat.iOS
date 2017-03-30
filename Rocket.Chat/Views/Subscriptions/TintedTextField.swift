//
//  TintedTextField.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 3/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class TintedTextField: UITextField {

    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearButton()
    }

    func tintClearButton() {
        for subview in subviews {
            if let clearButton = subview as? UIButton {
                let normalImage = clearButton.image(for: .normal)
                let tintedImage = normalImage?.withRenderingMode(.alwaysTemplate)
                clearButton.setImage(tintedImage, for: .normal)
                clearButton.setImage(tintedImage, for: .highlighted)
            }
        }
    }
}
