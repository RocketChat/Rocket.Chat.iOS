//
//  NewRoomViewController.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

class NewRoomViewController: BaseViewController {

    let tableViewData: [CreateCell] = [
        CreateCell(
            cell: .boolOption(title: "Public Channel", description: "Everyone can access this channel"),
            key: "public room",
            defaultValue: true
        ),
        CreateCell(
            cell: .boolOption(title: "Read only channel", description: "Only admin can write new messages"),
            key: "read only room",
            defaultValue: false
        ),
        CreateCell(
            cell: .textField(title: "Channel Name"),
            key: "room name",
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

    fileprivate enum TypeAlerts {
        case errorMessage(String)
        case errorUnknown

        func message() -> String {
            switch self {
            case .errorMessage(let message):
                return message
            case .errorUnknown:
                return localized("error.socket.default_error_message")
            }
        }
    }

    fileprivate func showAlert(_ typeAlert: TypeAlerts) {
        let alert = UIAlertController(
            title: localized("error.socket.default_error_title"),
            message: typeAlert.message(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
        DispatchQueue.main.sync {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func buttonCreateDidPressed(_ sender: Any) {
        guard let roomName = setValues["room name"] as? String else { return }
        guard let publicRoom = setValues["public room"] as? Bool else { return }
        guard let readOnlyRoom = setValues["read only room"] as? Bool else { return }

        let roomType: RoomCreateType
        if publicRoom {
            roomType = .channel
        } else {
            roomType = .group
        }

        API.shared.fetch(RoomCreateRequest(roomName: roomName, type: roomType, readOnly: readOnlyRoom)) { [weak self] result in

            guard let success = result?.raw?["success"].boolValue,
                success == true else {
                    if let errorMessage = result?.raw?["error"].string {
                        self?.showAlert(.errorMessage(errorMessage))
                    } else {
                        self?.showAlert(.errorUnknown)
                    }
                    return
            }

            guard let auth = AuthManager.isAuthenticated() else { return }

            SubscriptionManager.updateSubscriptions(auth) { _ in
                if let findNewRoom = Realm.shared?.objects(Subscription.self).filter("name == '\(roomName)'").first {
                    let newRoom = findNewRoom

                    let controller = ChatViewController.shared
                    controller?.subscription = newRoom

                    self?.dismiss(animated: true, completion: nil)
                } else {
                    self?.showAlert(.errorUnknown)
                }
            }
        }
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension NewRoomViewController: NewChannelCellDelegate {
    func updateDictValue(key: String, value: Any) {
        setValues[key] = value
    }

    func getPreviousValue(key: String) -> Any? {
        return setValues[key]
    }
}

// MARK: UITableViewDelegate

extension NewRoomViewController: UITableViewDelegate {

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

extension NewRoomViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
