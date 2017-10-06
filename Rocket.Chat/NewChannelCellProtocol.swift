//
//  NewChannelCellProtocol.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol NewChannelCellDelegate: class {
    func updateDictValue(key: String, value: Any)
    func getPreviousValue(key: String) -> Any?
}

protocol NewChannelCellProtocol {
    static var identifier: String { get }
    static var defaultHeight: Float { get }

    var delegate: NewChannelCellDelegate? { get set }
    var key: String? { get set }
    func setPreviousValue(previous: Any)
}

struct CreateCell {
    let cell: NewChannelCells
    let key: String
    let defaultValue: Any
}

enum NewChannelCells {
    case boolOption(title: String, description: String)
    case textField(placeholder: String?, icon: UIImage?)

    func getClass() -> NewChannelCellProtocol.Type {
        switch self {
        case .boolOption:
            return NewChannelBoolOptionCell.self
        case .textField:
            return NewChannelTextFieldCell.self
        }
    }

    func getIdentifier() -> String {
        return getClass().identifier
    }

    func createCell(table: UITableView, delegate: NewChannelCellDelegate, key: String) -> NewChannelCellProtocol? {
        let cellIdentifier = self.getIdentifier()
        guard var cell = table.dequeueReusableCell(withIdentifier: cellIdentifier) as? NewChannelCellProtocol else { return nil }

        switch self {
        case .boolOption(let title, let description):
            if let cell = cell as? NewChannelBoolOptionCell {
                cell.labelTitle.text = title
                cell.labelDescription.text = description
            }

        case .textField(let placeholder, let icon):
            if let cell = cell as? NewChannelTextFieldCell {
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
