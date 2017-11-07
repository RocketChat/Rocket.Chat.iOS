//
//  FormTableViewCell.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

protocol FormTableViewDelegate: NSObjectProtocol {
    func updateDictValue(key: String, value: Any)
    func getPreviousValue(key: String) -> Any?
}

protocol FormTableViewCellProtocol {
    static var identifier: String { get }
    static var xibFileName: String { get }
    static var defaultHeight: Float { get }

    var delegate: FormTableViewDelegate? { get set }
    var key: String? { get set }
    func setPreviousValue(previous: Any)
}

extension FormTableViewCellProtocol {
    static func registerCell(for table: UITableView) {
        let cellNib = UINib(nibName: self.xibFileName, bundle: nil)
        table.register(cellNib, forCellReuseIdentifier: self.identifier)
    }
}

struct SectionForm {
    let name: String?
    let footer: String?
    let cells: [FormCell]
}

struct FormCell {
    let cell: FormTableViewCell
    let key: String
    let defaultValue: Any
    let enabled: Bool
}

enum FormTableViewCell {
    case check(title: String, description: String)
    case textField(placeholder: String?, icon: UIImage?)

    func getClass() -> FormTableViewCellProtocol.Type {
        switch self {
        case .check:
            return CheckTableViewCell.self
        case .textField:
            return TextFieldTableViewCell.self
        }
    }

    func getIdentifier() -> String {
        return getClass().identifier
    }

    func createCell(table: UITableView, delegate: FormTableViewDelegate, key: String, enabled: Bool = true) -> FormTableViewCellProtocol? {
        let cellIdentifier = self.getIdentifier()
        guard var cell = table.dequeueReusableCell(withIdentifier: cellIdentifier) as? FormTableViewCellProtocol else { return nil }

        switch self {
        case .check(let title, let description):
            if let cell = cell as? CheckTableViewCell {
                cell.labelTitle.text = title
                cell.labelDescription.text = description
                cell.switchOption.isEnabled = enabled
            }

        case .textField(let placeholder, let icon):
            if let cell = cell as? TextFieldTableViewCell {
                cell.textFieldInput.placeholder = placeholder
                cell.imgLeftIcon.image = icon
                cell.textFieldInput.isEnabled = enabled
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
