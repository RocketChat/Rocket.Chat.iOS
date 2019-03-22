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
            pickerView.reloadAllComponents()
        }
    }

    private func configureStatusEnumModel() {
        guard let model = cellModel as? SettingModel<SubscriptionNotificationsStatus> else {
            return
        }

        titleLabel.text = model.title

        model.value.clearListeners()
        model.value.bindAndFire { [unowned self] value in
            self.valueLabel.text = value.localizedCase
        }

        model.pickerVisible.clearListeners()
        model.pickerVisible.bindAndFire { [unowned self] visible in
            self.pickerView.isHidden = !visible

            guard let index = model.options.index(of: model.value.value) else {
                return
            }

            DispatchQueue.main.async {
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    private func configureAudioEnumModel() {
        guard let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> else {
            return
        }

        titleLabel.text = model.title

        model.value.clearListeners()
        model.value.bindAndFire { [unowned self] value in
            self.valueLabel.text = value.localizedCase
        }

        model.pickerVisible.clearListeners()
        model.pickerVisible.bindAndFire { [unowned self] visible in
            self.pickerView.isHidden = !visible

            guard let index = model.options.index(of: model.value.value) else {
                return
            }

            DispatchQueue.main.async {
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    private func configureIntModel() {
        guard let model = cellModel as? SettingModel<Int> else {
            return
        }

        titleLabel.text = model.title

        model.value.clearListeners()
        model.value.bindAndFire { [unowned self] value in
            self.valueLabel.text = value == 0 ? localized("myaccount.settings.notifications.duration.default") : "\(value) \(localized("myaccount.settings.notifications.duration.seconds"))"
        }

        model.pickerVisible.clearListeners()
        model.pickerVisible.bindAndFire { [unowned self] visible in
            self.pickerView.isHidden = !visible

            guard let index = model.options.index(of: model.value.value) else {
                return
            }

            DispatchQueue.main.async {
                self.pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
}

extension NotificationsChooseCell: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let title: String
        if let model = cellModel as? SettingModel<SubscriptionNotificationsStatus> {
            title = model.options[row].localizedCase
        } else if let model = cellModel as? SettingModel<SubscriptionNotificationsAudioValue> {
            title = model.options[row].localizedCase
        } else if let model = cellModel as? SettingModel<Int> {
            let value = model.options[row]
            title = value == 0 ? localized("myaccount.settings.notifications.duration.default") : "\(value) \(localized("myaccount.settings.notifications.duration.seconds"))"
        } else {
            fatalError("Model not supported")
        }

        let pickerLabel = UILabel()
        pickerLabel.textColor = theme?.titleText ?? .black
        pickerLabel.text = title
        pickerLabel.textAlignment = .center
        pickerLabel.font = UIFont.systemFont(ofSize: 20)

        return pickerLabel
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
