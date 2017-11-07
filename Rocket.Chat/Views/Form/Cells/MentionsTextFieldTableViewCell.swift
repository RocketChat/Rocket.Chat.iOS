//
//  MentionsTextFieldTableViewCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 07.11.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class MentionsTextFieldTableViewCell: UITableViewCell, FormTableViewCellProtocol {
    static let identifier = "kMentionsTextFieldTableViewCell"
    static let xibFileName = "MentionsTextFieldTableViewCell"
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
