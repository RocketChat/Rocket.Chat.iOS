//
//  ColorPickerView.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 24.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate: class {
    func colorPicker(_ picker: ColorPickerView, didPick color: UIColor)
}

final class ColorPickerView: UIView {
    var axisX: CGFloat = 0
    weak var delegate: ColorPickerDelegate?

    override func draw(_ rect: CGRect) {
        let width = Int(frame.size.width)
        for idx in 0 ..< width {
            let color = UIColor(hue: CGFloat(idx)/frame.size.width, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            color.set()
            let rect = CGRect(x: CGFloat(idx), y: 0, width: 1.0, height: frame.size.height)
            UIRectFill(rect)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateColor(touch: touches.first)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateColor(touch: touches.first)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateColor(touch: touches.first)
    }

    func updateColor(touch: UITouch?) {
        guard let touch = touch else {
            return
        }

        axisX = (touch.location(in: self).x)

        let color = UIColor(hue: (axisX / frame.size.width), saturation: 1.0, brightness: 1.0, alpha: 1.0)
        delegate?.colorPicker(self, didPick: color)
    }
}
