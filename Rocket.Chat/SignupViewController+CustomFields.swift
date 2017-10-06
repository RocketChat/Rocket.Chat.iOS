//
//  SignInViewController+CustomFields.swift
//  Rocket.Chat
//
//  Created by Vadym Brusko on 10/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension SignupViewController {
    func setupCustomFields() {
        customTextFields = getCustomTextFields()
        for textField in customTextFields {
            fieldsContainer.addArrangedSubview(textField)
            fieldsContainer.addArrangedSubview(createSeparatorView())
        }
        exchangePasswordFieldWithLast()
    }

    private func getCustomTextFields() -> [UITextField] {
        return AuthSettingsManager.settings?.customFields.map { customField in
            createTextField(with: customField.name)
            } ?? []
    }

    private func createTextField(with name: String) -> UITextField {
        let textField = UITextField()
        textField.heightAnchor.constraint(equalToConstant: 62).isActive = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.placeholder = name
        textField.delegate = self
        return textField
    }

    private func createSeparatorView() -> UIView {
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = UIColor.RCSeparatorGrey()
        return separator
    }

    private func exchangePasswordFieldWithLast() {
        fieldsContainer.removeArrangedSubview(textFieldPassword)
        fieldsContainer.addArrangedSubview(textFieldPassword)
    }
}
