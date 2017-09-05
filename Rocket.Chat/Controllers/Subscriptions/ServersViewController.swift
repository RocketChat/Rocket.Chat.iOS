//
//  ServersViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

class ServersViewController: UIViewController {

    var servers: [[String: String]] = []

    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        servers = DatabaseManager.servers ?? []
        tableView?.reloadData()
    }

}

extension ServersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == servers.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddServerCell.identifier) as? AddServerCell else {
                return UITableViewCell()
            }

            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerCell.identifier) as? ServerCell else {
            return UITableViewCell()
        }

        cell.server = servers[indexPath.row]
        return cell
    }

}

extension ServersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == servers.count {
            MainChatViewController.shared?.openAddNewTeamController()
        } else {
            if indexPath.row == DatabaseManager.selectedIndex {
                SubscriptionsPageViewController.shared?.showSubscriptionsList()
            } else {
                MainChatViewController.shared?.changeSelectedServer(index: indexPath.row)
            }
        }
    }

}
