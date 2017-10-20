//
//  TextFieldTableViewCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class TextFieldTableViewCell: UITableViewCell, FormTableViewCellProtocol {
    static let identifier = "kTextFieldTableViewCell"
    static let xibFileName = "TextFieldTableViewCell"
    static let defaultHeight: Float = 44
    weak var delegate: FormTableViewDelegate?
    var key: String?

    @IBOutlet weak var imgLeftIcon: UIImageView!
    @IBOutlet weak var textFieldInput: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()

        textFieldInput.clearButtonMode = .whileEditing
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
