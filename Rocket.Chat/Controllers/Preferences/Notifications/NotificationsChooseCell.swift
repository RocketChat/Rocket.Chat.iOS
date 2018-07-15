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
        let pickerVisible: Dynamic<Bool>
    }

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var pickerView: UIPickerView! {
        didSet {
            pickerView.delegate = self
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

        model.value.bindAndFire { [unowned self] value in
            self.valueLabel.text = value.localizedCase
        }

        model.pickerVisible.bindAndFire { [unowned self] visible in
            self.pickerView.isHidden = !visible
        }
    }

    private func configureAudioEnumModel() {
        guard let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> else {
            return
        }

        titleLabel.text = model.title

        model.value.bindAndFire { [unowned self] value in
            self.valueLabel.text = value.localizedCase
        }

        model.pickerVisible.bindAndFire { [unowned self] visible in
            self.pickerView.isHidden = !visible
        }
    }

    private func configureIntModel() {
        guard let model = cellModel as? SettingModel<Int> else {
            return
        }

        titleLabel.text = model.title

        model.value.bindAndFire { [unowned self] value in
            self.valueLabel.text = value == 0 ? localized("myaccount.settings.notifications.duration.default") : "\(value) \(localized("myaccount.settings.notifications.duration.seconds"))"
        }

        model.pickerVisible.bindAndFire { [unowned self] visible in
            self.pickerView.isHidden = !visible
        }
    }
}

extension NotificationsChooseCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {

        let title: String
        if let model = cellModel as? SettingModel<SubscriptionNotificationsStatus> {
            title = model.options[row].localizedCase
        } else if let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> {
            title = model.options[row].localizedCase
        } else if let model = cellModel as? SettingModel<Int> {
            let value = model.options[row]
            title = value == 0 ? localized("myaccount.settings.notifications.duration.default") : "\(value) \(localized("myaccount.settings.notifications.duration.seconds"))"
        } else {
            title = ""
        }

        return NSAttributedString(string: title, attributes: [
            NSAttributedStringKey.foregroundColor: UIColor(hex: "3C7AFF"),
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)
            ])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let model = cellModel as? SettingModel<SubscriptionNotificationsStatus> {
            model.value.value = model.options[row]
        } else if let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> {
            model.value.value = model.options[row]
        } else if let model = cellModel as? SettingModel<Int> {
            model.value.value = model.options[row]
        }
    }
}

extension NotificationsChooseCell: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let model = cellModel as? SettingModel<SubscriptionNotificationsStatus> {
            return model.options.count
        } else if let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> {
            return model.options.count
        } else if let model = cellModel as? SettingModel<Int> {
            return model.options.count
        }

        return 0
    }
}
