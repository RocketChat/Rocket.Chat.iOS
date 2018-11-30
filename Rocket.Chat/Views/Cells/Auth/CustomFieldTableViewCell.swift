//
//  CustomFieldTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 14/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class CustomFieldTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: StyledTextField!

    var customField: CustomField! {
        didSet {
            setupCustomField(with: customField)
        }
    }

    var delegateReference: PickerViewDelegate!

    private func setupCustomField(with model: CustomField) {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.placeholder = model.name

        if let selectField = model as? SelectField {
            setupSelectField(textField, with: selectField)
        }
    }

    private func setupSelectField(_ textField: UITextField, with model: SelectField) {
        let pickerView = UIPickerView()

        let pickerDelegate = PickerViewDelegate(data: model.options) {
            textField.text = $0
        }

        delegateReference = pickerDelegate
        pickerView.dataSource = pickerDelegate
        pickerView.delegate = pickerDelegate
        pickerView.showsSelectionIndicator = true
        textField.inputView = pickerView
        textField.text = model.defaultValue
    }

}

extension CustomFieldTableViewCell {
    override func applyTheme() { }
}
