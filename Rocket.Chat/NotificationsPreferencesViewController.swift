//
//  NotificationsPreferencesViewController.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsPreferencesViewController: UITableViewController {
    private let viewModel = NotificationsPreferencesViewModel()
    var subscription: Subscription?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        viewModel.enableModel.value.bind { [unowned self] _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let subscription = subscription else {
            return
        }

        let request = SubscriptionGetOneRequest(roomId: subscription.rid)
        API.current()?.fetch(request, succeeded: { result in
            guard let subscription = result.subscription else {
                return
            }

            self.viewModel.enableModel.value.value = !subscription.disableNotifications
            self.viewModel.counterModel.value.value = !subscription.hideUnreadStatus
            self.viewModel.desktopAlertsModel.value.value = subscription.desktopNotifications.rawValue
            self.viewModel.desktopAudioModel.value.value = subscription.audioNotifications.rawValue
            self.viewModel.desktopSoundModel.value.value = subscription.audioNotificationValue.rawValue
            self.viewModel.desktopDurationModel.value.value = subscription.desktopNotificationDuration > 0 ? "\(String(subscription.desktopNotificationDuration)) seconds" : "default"
            self.viewModel.mobileAlertsModel.value.value = subscription.mobilePushNotifications.rawValue
            self.viewModel.mailAlertsModel.value.value = subscription.emailNotifications.rawValue

            }, errored: { _ in
                Alert.defaultError.present()
        })
    }
}

extension NotificationsPreferencesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settingsCells.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settingsCells[section].elements.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.settingsCells[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingModel = viewModel.settingsCells[indexPath.section].elements[indexPath.row]

        guard var cell = tableView.dequeueReusableCell(withIdentifier: settingModel.type.rawValue, for: indexPath) as? UITableViewCell & NotificationsCellProtocol else {
            fatalError("Could not dequeue reusable cell with type \(settingModel.type.rawValue)")
        }

        cell.cellModel = settingModel

        return cell
    }
}

extension NotificationsPreferencesViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingModel = viewModel.settingsCells[indexPath.section].elements[indexPath.row]
    }
}
