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

    func createCell(table: UITableView, delegate: NewChannelCellDelegate, key: String) -> NewChannelCellProtocol? {
        guard let cell = table.dequeueReusableCell(withIdentifier: NewChannelBoolOptionCell.identifier) as? NewChannelBoolOptionCell else {
            return nil
        }

        cell.delegate = delegate
        cell.key = key

        if let previousValue = cell.delegate?.getPreviousValue(key: key) {
            cell.setPreviousValue(previous: previousValue)
        }

        switch self {
        case .boolOption(let title, let description):
            cell.labelTitle.text = title
            cell.labelDescription.text = description
        }

        return cell
    }
}
