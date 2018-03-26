//
//  NotificationsSwitchCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsSwitchCell: UITableViewCell, NotificationsCellProtocol {
    struct SettingModel: NotificationSettingModel {
        var value: String
        var type: NotificationCellType
        let leftTitle: String
        let leftDescription: String
        let rightTitle: String
        let rightDescription: String

        init(value: String, type: NotificationCellType, leftTitle: String, leftDescription: String, rightTitle: String, rightDescription: String) {
            self.value = value
            self.type = type
            self.leftTitle = leftTitle
            self.leftDescription = leftDescription
            self.rightTitle = rightTitle
            self.rightDescription = rightDescription
        }
    }

    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftDescriptionLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightDescriptionLabel: UILabel!
    @IBOutlet weak var turnSwitch: UISwitch!

    var cellModel: NotificationSettingModel? {
        didSet {
            guard let model = cellModel as? SettingModel else {
                return
            }

            leftTitleLabel.text = model.leftTitle
            leftDescriptionLabel.text = model.leftDescription
            rightTitleLabel.text = model.rightTitle
            rightDescriptionLabel.text = model.rightDescription
            turnSwitch.isOn = model.value.boolValue

            leftTitleLabel.textColor = model.value.boolValue ? .lightGray : .black
            leftDescriptionLabel.textColor = model.value.boolValue ? .lightGray : .black
            rightTitleLabel.textColor = model.value.boolValue ? .black : .lightGray
            rightDescriptionLabel.textColor = model.value.boolValue ? .black : .lightGray
        }
    }
}
