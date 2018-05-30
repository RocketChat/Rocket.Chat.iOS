//
//  ServersListView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 28/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class ServersListView: UIView {

    private lazy var serversList: [[String: String]] = DatabaseManager.servers ?? []

    private var viewHeight: CGFloat {
        return CGFloat(min(serversList.count, 6)) * ServerCell.cellHeight
    }

    private var initialTableViewPosition: CGFloat {
        return (-viewHeight) - 80
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
    @IBOutlet weak var headerViewTopConstraint: NSLayoutConstraint! {
        didSet {
            headerViewTopConstraint.constant = initialTableViewPosition
        }
    }

    @IBOutlet weak var tableViewHeighConstraint: NSLayoutConstraint! {
        didSet {
            tableViewHeighConstraint.constant = viewHeight
        }
    }

    private func animates(_ animations: @escaping VoidCompletion, completion: VoidCompletion? = nil) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(rawValue: 7 << 16), animations: {
            animations()
        }, completion: { finished in
            if finished {
                completion?()
            }
        })
    }

    // MARK: Showing the View

    static func showIn(_ view: UIView) -> ServersListView? {
        guard let instance = ServersListView.instantiateFromNib() else { return nil }
        instance.backgroundColor = UIColor.black.withAlphaComponent(0)
        instance.frame = view.bounds
        view.addSubview(instance)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            instance.headerViewTopConstraint.constant = 0

            instance.animates({
                instance.backgroundColor = UIColor.black.withAlphaComponent(0.4)
                instance.layoutIfNeeded()
            })
        }

        return instance
    }

    // MARK: Hiding the View

    func close() {
        headerViewTopConstraint.constant = initialTableViewPosition

        animates({
            self.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.layoutIfNeeded()
        }, completion: {
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
        var serverName = ""

        if serversList.count > indexPath.row {
            serverName = serversList[indexPath.row][ServerPersistKeys.serverName] ?? ""
        }

        var alert = Alert(
            title: localized("servers.action.disconnect.alert.title"),
            message: String(format: localized("servers.action.disconnect.alert.message"), serverName)
        )

        alert.actions.append(UIAlertAction(title: localized("servers.action.disconnect.alert.confirm"), style: .destructive, handler: { _ in
            API.server(index: indexPath.row)?.client(PushClient.self).deletePushToken()
            DatabaseManager.removeDatabase(at: indexPath.row)

            self.serversList = DatabaseManager.servers ?? []
            self.tableView.reloadData()
            self.tableViewHeighConstraint.constant = self.viewHeight

            self.animates({
                self.layoutIfNeeded()
            })
        }))

        alert.actions.append(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))
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

        let disconnectAction = UITableViewRowAction(style: .destructive, title: localized("servers.action.disconnect"), handler: { (_, indexPath) in
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