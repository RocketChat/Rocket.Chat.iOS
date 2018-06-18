//
//  EmailAuthTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class EmailAuthTableViewCell: UITableViewCell {

    static let rowHeight: CGFloat = 164
    static let rowHeightBelowSeparator: CGFloat = 134

    @IBOutlet weak var loginButton: StyledButton!
    @IBOutlet weak var registerButton: StyledButton! {
        didSet {
            registerButton.setTitle(localized("auth.login.buttonRegister"), for: .normal)
        }
    }

}
