//
//  DrawingBrushOpacityViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 11.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingBrushOpacityViewController: UIViewController {
    weak var delegate: DrawingBrushOpacityDelegate?

    @IBAction func opacityChanged(_ sender: UISlider) {
        delegate?.brushOpacityChanged(opacity: CGFloat(sender.value))
    }
}
