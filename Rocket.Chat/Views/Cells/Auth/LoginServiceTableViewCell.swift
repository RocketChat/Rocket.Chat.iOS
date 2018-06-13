//
//  LoginServiceTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class LoginServiceTableViewCell: UITableViewCell {

    static let identifier = "LoginService"
    static let rowHeight: CGFloat = 56
    static let firstRowHeight: CGFloat = 82
    static let lastRowHeight: CGFloat = 52

    @IBOutlet weak var loginServiceButton: StyledButton!
    @IBOutlet weak var loginServiceBottomConstraint: NSLayoutConstraint!

    var defaultTextColor: UIColor!
    var defaultBorderColor: UIColor!
    var defaultButtonColor: UIColor!

    var loginService: LoginService! {
        didSet {
            updateLoginService()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        defaultTextColor = loginServiceButton.textColor
        defaultBorderColor = loginServiceButton.borderColor
        defaultButtonColor = loginServiceButton.buttonColor
    }

    func updateLoginService() {
        if let icon = loginService.type.icon {
            loginServiceButton.style = .outline
            loginServiceButton.textColor = defaultTextColor
            loginServiceButton.borderColor = defaultBorderColor
            loginServiceButton.buttonColor = defaultButtonColor
            loginServiceButton.applyStyle()

            let prefix = NSAttributedString(
                string: localized("auth.login_service_prefix"),
                attributes: [
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .regular)
                ]
            )
            let service = NSAttributedString(
                string: loginService.service?.capitalized ?? "",
                attributes: [
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .bold)
                ]
            )

            let combinedString = NSMutableAttributedString(attributedString: prefix)
            combinedString.append(service)

            loginServiceButton.setAttributedTitle(combinedString, for: .normal)
            loginServiceButton.setImage(icon, for: .normal)
        } else {
            loginServiceButton.style = .solid
            loginServiceButton.textColor = UIColor(hex: loginService.buttonLabelColor)
            loginServiceButton.borderColor = .clear
            loginServiceButton.buttonColor = UIColor(hex: loginService.buttonColor)
            loginServiceButton.fontSize = 16
            loginServiceButton.fontWeight = .bold
            loginServiceButton.applyStyle()

            loginServiceButton.setTitle(loginService.buttonLabelText, for: .normal)
        }
    }

}
