//
//  ConfigTableCellProtocol.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol ConfigTableCellDelegate: class {
    func updateDictValue(key: String, value: Any)
    func getPreviousValue(key: String) -> Any?
}

protocol ConfigTableCellProtocol {
    static var identifier: String { get }
    static var defaultHeight: Float { get }

    var delegate: ConfigTableCellDelegate? { get set }
    var key: String? { get set }
    func setPreviousValue(previous: Any)
}

struct GroupOfConfigCell {
    let name: String?
    let footer: String?
    let cells: [ConfigTableCell]
}

struct ConfigTableCell {
    let cell: ConfigTableCells
    let key: String
    let defaultValue: Any
}

enum ConfigTableCells {
    case boolOption(title: String, description: String)
    case textField(placeholder: String?, icon: UIImage?)

    func getClass() -> ConfigTableCellProtocol.Type {
        switch self {
        case .boolOption:
            return ConfigTableCellBoolOptionCell.self
        case .textField:
            return ConfigTableCellTextFieldCell.self
        }
    }

    func getIdentifier() -> String {
        return getClass().identifier
    }

    func createCell(table: UITableView, delegate: ConfigTableCellDelegate, key: String) -> ConfigTableCellProtocol? {
        let cellIdentifier = self.getIdentifier()
        guard var cell = table.dequeueReusableCell(withIdentifier: cellIdentifier) as? ConfigTableCellProtocol else { return nil }

        switch self {
        case .boolOption(let title, let description):
            if let cell = cell as? ConfigTableCellBoolOptionCell {
                cell.labelTitle.text = title
                cell.labelDescription.text = description
            }

        case .textField(let placeholder, let icon):
            if let cell = cell as? ConfigTableCellTextFieldCell {
                cell.textFieldInput.placeholder = placeholder
                cell.imgRoomIcon.image = icon
            }
        }

        cell.delegate = delegate
        cell.key = key

        if let previousValue = cell.delegate?.getPreviousValue(key: key) {
            cell.setPreviousValue(previous: previousValue)
        }

        return cell
    }
}
