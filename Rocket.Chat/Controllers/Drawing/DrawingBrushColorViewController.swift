//
//  DrawingBrushColorViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 11.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class DrawingBrushColorViewController: UIViewController {
    weak var delegate: DrawingBrushColorDelegate?

    private var color = UIColor.black

    func setCurrentColor(_ color: UIColor) {
        self.color = color
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = color // temp
    }
}
