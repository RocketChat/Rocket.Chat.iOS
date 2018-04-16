//
//  NotificationsChooseCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsChooseCell: UITableViewCell, NotificationsCellProtocol {
    struct SettingModel: NotificationSettingModel {
        let value: Dynamic<String>
        let options: [String]
        var type: NotificationCellType
        let title: String

        init(value: Dynamic<String>, options: [String], type: NotificationCellType, title: String) {
            self.value = value
            self.options = options
            self.type = type
            self.title = title
        }
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueField: DropDownMenu!
    weak var tableView: UITableView? {
        didSet {
            valueField.parentView = tableView
        }
    }
    var dropDownRect: CGRect = .zero {
        didSet {
            valueField.dropDownRect = dropDownRect
        }
    }

    var cellModel: NotificationSettingModel? {
        didSet {
            guard let model = cellModel as? SettingModel else {
                return
            }

            titleLabel.text = model.title
            valueField.options = model.options
            valueField.didSelectItem = { index in
                model.value.value = model.options[index]
            }

            model.value.bindAndFire { [unowned self] value in
                self.valueField.defaultValue = value
            }
        }
    }
}
