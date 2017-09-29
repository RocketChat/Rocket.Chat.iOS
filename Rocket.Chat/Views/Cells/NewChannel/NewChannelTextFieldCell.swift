//
//  NewChannelTextFieldCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class NewChannelTextFieldCell: UITableViewCell, NewChannelCellProtocol {
    static let identifier = "kNewChannelTextField"
    static let defaultHeight: Float = 68
    weak var delegate: NewChannelCellDelegate?
    var key: String?

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textFieldInput: UITextField!

    func setPreviousValue(previous: Any) {
        if let previous = previous as? String {
            textFieldInput.text = previous
        }
    }

    @IBAction func textFieldInputEditingChanged(_ sender: Any) {
        delegate?.updateDictValue(key: key ?? "", value: textFieldInput.text ?? "")
    }
}
