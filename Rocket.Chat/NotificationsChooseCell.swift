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
        var type: NotificationCellType
        let title: String

        init(value: Dynamic<String>, type: NotificationCellType, title: String) {
            self.value = value
            self.type = type
            self.title = title
        }
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueField: DropDownMenu! {
        didSet {
            valueField.options = ["1", "2", "3", "4"]
        }
    }

    var cellModel: NotificationSettingModel? {
        didSet {
            guard let model = cellModel as? SettingModel else {
                return
            }

            titleLabel.text = model.title
            model.value.bindAndFire { [unowned self] value in
                self.valueField.defaultValue = value
            }
        }
    }
}
