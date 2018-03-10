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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        API.current()?.client(SettingsClient.self).fetchSettings()
    }
}

extension NotificationsPreferencesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.settings.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.settings[section].elements.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.settings[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingModel = viewModel.settings[indexPath.section].elements[indexPath.row]

        switch settingModel.type {
        case .switch:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingModel.type.rawValue, for: indexPath) as? NotificationsSwitchCell else {
                fatalError("Could not dequeue reusable cell with type \(settingModel.type.rawValue)")
            }

            cell.leftTitleLabel.text = settingModel.title
            cell.rightTitleLabel.text = settingModel.title

            return cell
        case .list:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: settingModel.type.rawValue, for: indexPath) as? NotificationsChooseCell else {
                fatalError("Could not dequeue reusable cell with type \(settingModel.type.rawValue)")
            }

            cell.titleLabel.text = settingModel.title

            return cell
        }
    }
}

extension NotificationsPreferencesViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingModel = viewModel.settings[indexPath.section].elements[indexPath.row]
    }
}
