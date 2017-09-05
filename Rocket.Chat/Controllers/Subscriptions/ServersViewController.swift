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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        servers = DatabaseManager.servers ?? []
    }

}

extension ServersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerCell.identifier) as? ServerCell else {
            return UITableViewCell()
        }

        cell.server = servers[indexPath.row]
        return cell
    }

}
