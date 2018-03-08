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

    private var opacity: Float = 1
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet weak var opacityLabel: UILabel!
    @IBOutlet weak var opacityTitle: UILabel! {
        didSet {
            opacityTitle.text = localized("chat.drawing.settings.opacity")
        }
    }

    @IBAction func opacityChanged(_ sender: UISlider) {
        opacityLabel.text = String(format: "%.2f", sender.value * 100).appending("%")
        delegate?.brushOpacityChanged(opacity: CGFloat(sender.value))
    }

    func setCurrectOpacity(_ opacity: CGFloat) {
        self.opacity = Float(opacity)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        opacityLabel.text = String(format: "%.2f", opacity * 100).appending("%")
        slider.value = opacity
    }
}
