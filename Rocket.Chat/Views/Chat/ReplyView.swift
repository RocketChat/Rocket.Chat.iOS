//
//  ReplyView.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 10/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class ReplyView: UIView {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var message: UILabel!

    var onClose: (() -> Void)?

    @IBAction func closePressed(_ sender: UIButton) {
        onClose?()
    }
}
