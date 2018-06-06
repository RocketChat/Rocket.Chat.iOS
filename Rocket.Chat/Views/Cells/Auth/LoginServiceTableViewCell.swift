//
//  LoginServiceTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class LoginServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var loginServiceButton: UIButton!

    var loginService: LoginService! {
        didSet {
            updateLoginService()
        }
    }

    func updateLoginService() {
        let suffix = NSAttributedString(string: "Connect with ", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .regular)]) // TODO: Localize
        let service = NSAttributedString(string: loginService.service?.capitalized ?? "", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold)])
        let combinedString = NSMutableAttributedString(attributedString: suffix)
        combinedString.append(service)

        loginServiceButton.setAttributedTitle(combinedString, for: .normal)
    }

}
