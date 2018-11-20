//
//  NotificationsPreferencesViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsPreferencesViewController: BaseTableViewController {
    private let viewModel = NotificationsPreferencesViewModel()
    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription else {
                return
            }

            viewModel.currentPreferences = NotificationPreferences(
                desktopNotifications: subscription.desktopNotifications,
                disableNotifications: subscription.disableNotifications,
                emailNotifications: subscription.emailNotifications,
                audioNotificationValue: subscription.audioNotificationValue,
                desktopNotificationDuration: subscription.desktopNotificationDuration,
                audioNotifications: subscription.audioNotifications,
                hideUnreadStatus: subscription.hideUnreadStatus,
                mobilePushNotifications: subscription.mobilePushNotifications
            )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        viewModel.enableModel.value.bind { [unowned self] _ in
            let updates = self.viewModel.tableUpdatesAfterStateChange()

            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.insertSections(updates.insertions, with: .fade)
                self.tableView.deleteSections(updates.deletions, with: .fade)
                self.tableView.endUpdates()
            }
        }

        viewModel.isSaveButtonEnabled.bindAndFire { enabled in
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.isEnabled = enabled
            }
        }
        viewModel.updateModel(subscription: subscription)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: viewModel.saveButtonTitle, style: .done, target: self, action: #selector(saveSettings))
    }

    @objc private func saveSettings() {
        guard let subscription = subscription else {
            Alert(key: "alert.update_notifications_preferences_save_error").present()
            return
        }

        let saveNotificationsRequest = SaveNotificationRequest(rid: subscription.rid, notificationPreferences: viewModel.notificationPreferences)
        API.current()?.fetch(saveNotificationsRequest) { [weak self] response in
            guard let self = self else { return }

            switch response {
            case .resource:
                self.viewModel.updateCurrentPreferences()
                self.alertSuccess(title: self.viewModel.saveSuccessTitle)
            case .error:
                Alert(key: "alert.update_notifications_preferences_save_error").present()
            }
        }
    }

}

extension NotificationsPreferencesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.titleForFooter(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingModel = viewModel.settingModel(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: settingModel.type.rawValue, for: indexPath)

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let settingModel = viewModel.settingModel(for: indexPath)
        guard var cell = cell as? NotificationsCellProtocol else {
            fatalError("Could not dequeue reusable cell with type \(settingModel.type.rawValue)")
        }

        cell.cellModel = settingModel
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()

        viewModel.openPicker(for: indexPath)

        tableView.endUpdates()
    }
}
