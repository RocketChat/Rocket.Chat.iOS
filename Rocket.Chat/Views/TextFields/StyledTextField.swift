//
//  StyledTextField.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 01/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class StyledTextField: VOTextField {

    @IBInspectable var leftIcon: UIImage?
    lazy var iconView: UIImageView = {
        let iconView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 20, height: 20))
        iconView.contentMode = .center
        iconView.image = self.leftIcon

        return iconView
    }()

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        leftView = iconView
        leftViewMode = .always
        applyStyle()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: leftIcon != nil ? 45 : 15, dy: 0)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let defaultRect = super.leftViewRect(forBounds: bounds)
        return CGRect(
            x: 15,
            y: defaultRect.origin.y,
            width: defaultRect.width,
            height: defaultRect.height
        )
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: leftIcon != nil ? 45 : 15, dy: 0)
    }

    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let defaultRect = super.clearButtonRect(forBounds: bounds)
        return CGRect(
            x: defaultRect.origin.x - 10,
            y: defaultRect.origin.y,
            width: defaultRect.width,
            height: defaultRect.height
        )
    }

    func applyStyle() {
        iconView.image = leftIcon

        clearButtonMode = .whileEditing

        textColor = UIColor.RCTextFieldGray()
        let placeholderText = placeholder ?? ""
        let placeholderAttributes = NSAttributedString(
            string: placeholderText,
            attributes: [
                NSAttributedStringKey.foregroundColor: UIColor.RCTextFieldGray(),
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .regular)
            ]
        )

        attributedPlaceholder = placeholder != nil ? placeholderAttributes : nil

        layer.cornerRadius = 2
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.RCTextFieldBorderGray().cgColor
    }

}
