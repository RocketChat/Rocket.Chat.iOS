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
        let value: Dynamic<Bool>
        var type: NotificationCellType
        let title: String
    }

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var turnSwitch: UISwitch!

    var cellModel: NotificationSettingModel? {
        didSet {
            guard let model = cellModel as? SettingModel else {
                return
            }

            titleLabel.text = model.title
            model.value.bindAndFire { [weak self] value in
                self?.turnSwitch.isOn = value
            }
        }
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
        guard let model = cellModel as? SettingModel else {
            return
        }

        model.value.value = sender.isOn
    }
}
