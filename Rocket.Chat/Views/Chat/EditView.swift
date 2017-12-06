//
//  EditView.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 06/12/2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class EditView: UIView {
    @IBOutlet weak var message: UILabel!

    var onClose: (() -> Void)?

    @IBAction func closePressed(_ sender: UIButton) {
        onClose?()
    }
}
