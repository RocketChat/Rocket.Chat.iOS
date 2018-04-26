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

    private var opacity: CGFloat = 1
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet weak var opacityLabel: UILabel!
    @IBOutlet weak var opacityTitle: UILabel! {
        didSet {
            opacityTitle.text = localized("chat.drawing.settings.opacity")
        }
    }

    @IBAction func opacityChanged(_ sender: UISlider) {
        let value = CGFloat(sender.value)
        opacityLabel.text = "\(String(format: "%.2f", value * 100))%"
        delegate?.brushOpacityChanged(opacity: value)
    }

    func setCurrectOpacity(_ opacity: CGFloat) {
        self.opacity = opacity
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        opacityLabel.text = "\(String(format: "%.2f", opacity * 100))%"
        slider.value = Float(opacity)
    }
}
