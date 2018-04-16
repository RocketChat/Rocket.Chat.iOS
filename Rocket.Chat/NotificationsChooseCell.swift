//
//  NotificationsChooseCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsChooseCell: UITableViewCell, NotificationsCellProtocol {
    struct SettingModel<T>: NotificationSettingModel {
        let value: Dynamic<T>
        let options: [T]
        var type: NotificationCellType
        let title: String

        init(value: Dynamic<T>, options: [T], type: NotificationCellType, title: String) {
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
            configureStatusEnumModel()
            configureAudioEnumModel()
            configureIntModel()
        }
    }

    private func configureStatusEnumModel() {
        guard let model = cellModel as? SettingModel<SubscriptionNotificationsStatus> else {
            return
        }

        titleLabel.text = model.title
        valueField.options = model.options.map({ status -> String in
            status.rawValue
        })
        valueField.didSelectItem = { index in
            model.value.value = model.options[index]
        }

        model.value.bindAndFire { [unowned self] value in
            self.valueField.defaultValue = value.rawValue
        }
    }

    private func configureAudioEnumModel() {
        guard let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> else {
            return
        }

        titleLabel.text = model.title
        valueField.options = model.options.map({ status -> String in
            status.rawValue
        })
        valueField.didSelectItem = { index in
            model.value.value = model.options[index]
        }

        model.value.bindAndFire { [unowned self] value in
            self.valueField.defaultValue = value.rawValue
        }
    }

    private func configureIntModel() {
        guard let model = cellModel as? SettingModel<Int> else {
            return
        }

        titleLabel.text = model.title
        valueField.options = model.options.map({ seconds -> String in
            "\(seconds) seconds"
        })
        valueField.didSelectItem = { index in
            model.value.value = model.options[index]
        }

        model.value.bindAndFire { [unowned self] value in
            self.valueField.defaultValue = value == 0 ? "default" : "\(value) seconds"
        }
    }
}
