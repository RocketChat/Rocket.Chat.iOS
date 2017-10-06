//
//  ConfigTableCellTextFieldCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class ConfigTableCellTextFieldCell: UITableViewCell, ConfigTableCellProtocol {
    static let identifier = "kConfigTableCellTextField"
    static let defaultHeight: Float = 40
    weak var delegate: ConfigTableCellDelegate?
    var key: String?

    @IBOutlet weak var imgRoomIcon: UIImageView!
    @IBOutlet weak var textFieldInput: UITextField!
    @IBOutlet weak var imgClearText: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        let gestureClearText = UITapGestureRecognizer(target: self, action: #selector(self.clearTextField))
        imgClearText.addGestureRecognizer(gestureClearText)
    }

    func setPreviousValue(previous: Any) {
        if let previous = previous as? String {
            textFieldInput.text = previous
        }
    }

    @IBAction func textFieldInputEditingChanged(_ sender: Any) {
        delegate?.updateDictValue(key: key ?? "", value: textFieldInput.text ?? "")
    }

    @objc func clearTextField(_ sender: Any) {
        textFieldInput.text = ""
        textFieldInputEditingChanged(sender)
    }
}
