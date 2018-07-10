//
//  TextFieldTableViewCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class TextFieldTableViewCell: UITableViewCell, FormTableViewCellProtocol {

    static let identifier = "kTextFieldTableViewCell"
    static let defaultHeight: Float = 50.0

    weak var delegate: FormTableViewDelegate?
    var key: String?
    var textLimit = 0

    @IBOutlet weak var imgLeftIcon: UIImageView!
    @IBOutlet weak var textFieldInput: UITextField! {
        didSet {
            textFieldInput.delegate = self
            textFieldInput.clearButtonMode = .whileEditing
        }
    }

    func setPreviousValue(previous: Any) {
        if let previous = previous as? String {
            textFieldInput.text = previous
        }
    }

    @IBAction func textFieldInputEditingChanged(_ sender: Any) {
        delegate?.updateDictValue(key: key ?? "", value: textFieldInput.text ?? "")
    }

}

extension TextFieldTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textLimit > 0 else { return true }
        guard let text = textField.text else { return true }

        let newLength = text.count + string.count
        return newLength <= 40
    }
}

// MARK: Themeable

extension TextFieldTableViewCell {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        imgLeftIcon.tintColor = theme.titleText
    }
}
