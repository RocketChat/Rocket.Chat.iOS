//
//  ConfigTableCellBoolOptionCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class ConfigTableCellBoolOptionCell: UITableViewCell, ConfigTableCellProtocol {
    static let identifier = "kConfigTableCellBoolOption"
    static let xibFileName = "ConfigTableCellBoolOptionCell"
    static let defaultHeight: Float = 56
    weak var delegate: ConfigTableCellDelegate?
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
