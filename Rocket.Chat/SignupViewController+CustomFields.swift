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
            createTextField(with: customField)
        } ?? []
    }

    private func createTextField(with model: CustomField) -> UITextField {
        let textField = UITextField()
        textField.heightAnchor.constraint(equalToConstant: 62).isActive = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.placeholder = model.name
        textField.delegate = self
        setupField(textField, with: model)
        return textField
    }

    private func setupField(_ textField: UITextField, with model: CustomField) {
        switch model {
        case let selectField as SelectField:
            setupSelectField(textField, with: selectField)
            break
        default:
            break
        }
    }

    private func setupSelectField(_ textField: UITextField, with model: SelectField) {
        let pickerView = UIPickerView()
        let pickerDelegate = PickerViewDelegate(source: model.options) {
            textField.text = $0
        }
        compoundPickerDelegate.append(pickerDelegate)
        pickerView.dataSource = pickerDelegate
        pickerView.delegate = pickerDelegate
        pickerView.showsSelectionIndicator = true
        textField.inputView = pickerView
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustScrollView()
    }

    func adjustScrollView() {
        fieldsContainerVerticalCenterConstraint.isActive = !needScrolling()
        fieldsContainerTopConstraint.isActive = needScrolling()
    }

    private func needScrolling() -> Bool {
        return fieldsContainer.bounds.height >= scrollView.bounds.height
    }
}
