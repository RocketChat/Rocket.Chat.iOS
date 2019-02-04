//
//  LoginServiceTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class LoginServiceTableViewCell: UITableViewCell {

    static let identifier = "LoginService"
    static let rowHeight: CGFloat = 56.0
    static let firstRowHeight: CGFloat = 82.0
    static let lastRowHeight: CGFloat = 52.0

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

            let font = UIFont.preferredFont(forTextStyle: .body)
            let prefix = NSAttributedString(
                string: localized("auth.login_service_prefix"),
                attributes: [
                    NSAttributedString.Key.font: font
                ]
            )
            let service = NSAttributedString(
                string: loginService.service?.capitalized ?? "",
                attributes: [
                    NSAttributedString.Key.font: font.bold() ?? font
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
            loginServiceButton.fontTraits = .traitBold
            loginServiceButton.applyStyle()

            loginServiceButton.setTitle(loginService.buttonLabelText, for: .normal)
        }
    }

}

// MARK: Disable Theming

extension LoginServiceTableViewCell {
    override func applyTheme() { }
}
