//
//  ButtonCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    static let identifier: String = "ButtonCell"
    @IBOutlet weak var button: UIButton!

    var press: (() -> Void)?
    @IBAction func didPress(_ sender: Any) {
        press?()
    }

    override func prepareForReuse() {
        self.button.titleLabel?.text = ""
    }
}
