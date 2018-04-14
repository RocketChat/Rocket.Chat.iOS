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
            self.tableView.reloadData()
        }

//        API.current()?.client(SettingsClient.self).fetchSettings()
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
