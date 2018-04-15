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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueField: DropDownMenu!

    var cellModel: NotificationSettingModel? {
        didSet {
            guard let model = cellModel as? SettingModel else {
                return
            }

            titleLabel.text = model.title
            valueField.options = model.options
            model.value.bindAndFire { [unowned self] value in
                self.valueField.defaultValue = value
            }
        }
    }
}
