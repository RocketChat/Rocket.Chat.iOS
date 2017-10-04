//
//  NewChannelViewController.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

class NewChannelViewController: BaseViewController {

    let tableViewData: [CreateCell] = [
        CreateCell(
            cell: .boolOption(title: "Public Channel", description: "Everyone can access this channel"),
            key: "Public Channel",
            defaultValue: true
        ),
        CreateCell(
            cell: .boolOption(title: "Read only channel", description: "Only admin can write new messages"),
            key: "Read only channel",
            defaultValue: false
        ),
        CreateCell(
            cell: .textField(title: "Channel Name"),
            key: "Channel Name",
            defaultValue: ""
        )
    ]

    lazy var setValues: [String: Any] = {
        return tableViewData.reduce([String: Any]()) { (dict, entry) in
            var ndict = dict
            ndict[entry.key] = entry.defaultValue
            return ndict
        }
    }()

    @IBOutlet weak var tableView: UITableView!

    @IBAction func buttonCreateDidPressed(_ sender: Any) {
        guard let channelName = setValues["Channel Name"] as? String else { return }
        guard let publicChannel = setValues["Public Channel"] as? Bool else { return }

        let channelType: ChannelCreateType
        if publicChannel {
            channelType = .channel
        } else {
            channelType = .group
        }

        API.shared.fetch(ChannelCreateRequest(channelName: channelName, type: channelType)) { [weak self] result in

            if let error = result?.raw?.error {
                // TODO: Need show the error message to user
                print(error)
                return
            }

            guard let auth = AuthManager.isAuthenticated() else { return }

            SubscriptionManager.updateSubscriptions(auth) { _ in
                if let findNewChannel = Realm.shared?.objects(Subscription.self).filter("name == '\(channelName)'").first {
                    let newChannel = findNewChannel

                    let controller = ChatViewController.shared
                    controller?.subscription = newChannel

                    self?.dismiss(animated: true, completion: nil)
                } else {
                    // TODO: Need show the error message to user
                    print("New channel not found")
                }
            }
        }
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NewChannelViewController: NewChannelCellDelegate {
    func updateDictValue(key: String, value: Any) {
        setValues[key] = value
    }

    func getPreviousValue(key: String) -> Any? {
        return setValues[key]
    }
}

// MARK: UITableViewDelegate

extension NewChannelViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section]

        if let newCell = data.cell.createCell(table: tableView, delegate: self, key: data.key) as? UITableViewCell {
            return newCell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewData[indexPath.section].cell.getClass().defaultHeight)
    }
}

// MARK: UITableViewDataSource

extension NewChannelViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
