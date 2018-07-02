//
//  DrawingBrushWidthViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 11.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingBrushWidthViewController: BaseViewController {
    weak var delegate: DrawingBrushWidthDelegate?

    private var width: Float = 1
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet weak var widthLabel: UILabel!
    @IBOutlet weak var widthTitle: UILabel! {
        didSet {
            widthLabel.text = localized("chat.drawing.settings.width")
        }
    }

    @IBAction func opacityChanged(_ sender: UISlider) {
        widthLabel.text = String(format: "%.2f", sender.value)
        delegate?.brushWidthChanged(width: CGFloat(sender.value))
    }

    func setCurrentWidth(_ width: CGFloat) {
        self.width = Float(width)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        widthLabel.text = String(format: "%.2f", width)
        slider.value = width
    }
}
