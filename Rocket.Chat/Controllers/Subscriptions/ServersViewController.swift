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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Long press to show some actions on cells
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        servers = DatabaseManager.servers ?? []
        tableView?.reloadData()
    }

    func selectServer(at indexPath: IndexPath) {
//        if indexPath.row == servers.count {
//            MainChatViewController.shared?.openAddNewTeamController()
//        } else {
//            if indexPath.row == DatabaseManager.selectedIndex {
//                SubscriptionsPageViewController.shared?.showSubscriptionsList()
//            } else {
//                MainChatViewController.shared?.changeSelectedServer(index: indexPath.row)
//            }
//        }
    }

    func removeServer(at indexPath: IndexPath) {
        DatabaseManager.removeDatabase(at: indexPath.row)
        servers = DatabaseManager.servers ?? []
        tableView.reloadData()
    }

    @objc func handleLongPress(gesture: UIGestureRecognizer) {
        let point = gesture.location(in: tableView)

        guard
            let indexPath = tableView.indexPathForRow(at: point),
            indexPath.row != DatabaseManager.selectedIndex,
            indexPath.row < servers.count
        else {
            return

        }

        let server = servers[indexPath.row]
        if gesture.state == UIGestureRecognizerState.began {
            var message: String?

            if let serverURL = URL(string: server[ServerPersistKeys.serverURL] ?? "") {
                message = serverURL.host
            }

            let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: localized("servers.action.connect"), style: .default, handler: { _ in
                self.selectServer(at: indexPath)
            }))

            alert.addAction(UIAlertAction(title: localized("servers.action.remove"), style: .destructive, handler: { _ in
                self.removeServer(at: indexPath)
            }))

            alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if DatabaseManager.selectedIndex == indexPath.row {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

}

extension ServersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectServer(at: indexPath)
    }

}
