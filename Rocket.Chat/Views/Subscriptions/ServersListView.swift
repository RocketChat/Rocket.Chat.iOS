//
//  ServersListView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 28/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class ServersListView: UIView {

    lazy var serversList: [[String: String]] = DatabaseManager.servers ?? []

    var viewHeight: CGFloat {
        return CGFloat(min(serversList.count, 6)) * ServerCell.cellHeight
    }

    var initialTableViewPosition: CGFloat {
        return (-viewHeight) - 70
    }

    @IBOutlet weak var headerView: UIView!

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self

            tableView.register(ServerCell.nib, forCellReuseIdentifier: ServerCell.identifier)
        }
    }

    // Start the constraint with negative value (view height + headerView height) so we can
    // animate it later when the view is presented.
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint! {
        didSet {
            tableViewTopConstraint.constant = initialTableViewPosition
        }
    }

    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeighConstraint.constant = viewHeight
        }
    }

    // MARK: Showing the View

    static func showIn(_ view: UIView) -> ServersListView? {
        guard let instance = ServersListView.instantiateFromNib() else { return nil }
        instance.backgroundColor = UIColor.black.withAlphaComponent(0)
        instance.headerView.alpha = 0
        instance.frame = view.bounds
        view.addSubview(instance)

        UIView.animate(withDuration: 0.2) {
            instance.headerView.alpha = 1
            instance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            instance.tableViewTopConstraint.constant = 0

            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
                instance.layoutIfNeeded()
            })
        }

        return instance
    }

    // MARK: Hiding the View

    func close() {
        tableViewTopConstraint.constant = initialTableViewPosition

        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut], animations: {
            self.headerView.alpha = 0
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    // MARK: Server Management

    @IBAction func buttonAddNewServerDidPressed(sender: Any) {
        WindowManager.open(.auth(serverUrl: "", credentials: nil))
    }

    func selectServer(at indexPath: IndexPath) {
        if indexPath.row == DatabaseManager.selectedIndex {
            close()
        } else {
            DatabaseManager.selectDatabase(at: indexPath.row)
            DatabaseManager.changeDatabaseInstance(index: indexPath.row)

            SocketManager.disconnect { (_, _) in
                WindowManager.open(.subscriptions)
            }

            AppManager.changeSelectedServer(index: indexPath.row)
        }
    }

    func removeServer(at indexPath: IndexPath) {
        var alert = Alert(title: "Disconnect from server", message: "Are you sure you want to disconnect")

        alert.actions.append(UIAlertAction(title: "Disconnect", style: .destructive, handler: { _ in
            API.server(index: indexPath.row)?.client(PushClient.self).deletePushToken()
            DatabaseManager.removeDatabase(at: indexPath.row)

            self.serversList = DatabaseManager.servers ?? []
            self.tableView.reloadData()
            self.tableViewHeighConstraint.constant = self.viewHeight

            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            })
        }))

        alert.actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.present()
    }

}

// MARK: UITableViewDataSource

extension ServersListView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serversList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServerCell.identifier) as? ServerCell else {
            return UITableViewCell()
        }

        if serversList.count > indexPath.row {
            cell.server = serversList[indexPath.row]
        }

        if DatabaseManager.selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServerCell.cellHeight
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if DatabaseManager.selectedIndex == indexPath.row {
            return []
        }

        let disconnectAction = UITableViewRowAction(style: .destructive, title: "Disconnect", handler: { (_, indexPath) in
            self.removeServer(at: indexPath)
        })

        return [disconnectAction]
    }

}

// MARK: UITableViewDelegate

extension ServersListView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectServer(at: indexPath)
    }

}
