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
        var value: String
        var type: NotificationCellType
        let title: String

        init(value: String, type: NotificationCellType, title: String) {
            self.value = value
            self.type = type
            self.title = title
        }
    }

    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    var cellModel: NotificationSettingModel? {
        didSet {
            guard let model = cellModel as? SettingModel else {
                return
            }

            titleLabel.text = model.title
            valueLabel.text = model.value
        }
    }
}
