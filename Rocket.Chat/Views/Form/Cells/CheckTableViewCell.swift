//
//  CheckTableViewCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class CheckTableViewCell: UITableViewCell, FormTableViewCellProtocol {

    static let identifier = "kCheckTableViewCell"
    static let defaultHeight: Float = 56

    weak var delegate: FormTableViewDelegate?
    var key: String?

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var switchOption: UISwitch!

    func setPreviousValue(previous: Any) {
        if let previous = previous as? Bool {
            switchOption.setOn(previous, animated: false)
        }
    }

    @IBAction func switchDidChangeValue(_ sender: UISwitch) {
        delegate?.updateDictValue(key: key ?? "", value: switchOption.isOn)
    }

}
