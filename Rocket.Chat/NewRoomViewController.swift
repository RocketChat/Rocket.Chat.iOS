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

    let tableViewData: [SectionForm] = [
        SectionForm(
            name: nil,
            footer: nil,
            cells: [
                FormCell(
                    cell: .check(title: localized("new_room.cell.public_channel.title"), description: localized("new_room.cell.public_chanell.description")),
                    key: "public room",
                    defaultValue: true
                ),
                FormCell(
                    cell: .check(title: localized("new_room.cell.read_only.title"), description: localized("new_room.cell.read_only.description")),
                    key: "read only room",
                    defaultValue: false
                )
            ]
        ),
        SectionForm(
            name: localized("new_room.group.channel.name"),
            footer: localized("new_room.group.channel.footer"),
            cells: [
                FormCell(
                    cell: .textField(placeholder: localized("new_room.cell.channel_name.title"), icon: #imageLiteral(resourceName: "Hashtag")),
                    key: "room name",
                    defaultValue: ""
                )
            ]
        )
    ]

    var referenceOfCells: [String: FormTableViewCellProtocol] = [:]
    lazy var setValues: [String: Any] = {
        return tableViewData.reduce([String: Any]()) { (dict, entry) in
            var ndict = dict
            entry.cells.forEach { ndict[$0.key] = $0.defaultValue }
            return ndict
        }
    }()

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        CheckTableViewCell.registerCell(for: tableView)
        TextFieldTableViewCell.registerCell(for: tableView)
    }

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

    @IBAction func buttonCreateDidPressed(_ sender: UIButton) {
        guard let roomName = setValues["room name"] as? String else { return }
        guard let publicRoom = setValues["public room"] as? Bool else { return }
        guard let readOnlyRoom = setValues["read only room"] as? Bool else { return }

        let roomType: RoomCreateType
        if publicRoom {
            roomType = .channel
        } else {
            roomType = .group
        }

        sender.isEnabled = false
        API.shared.fetch(RoomCreateRequest(roomName: roomName, type: roomType, readOnly: readOnlyRoom)) { [weak self] result in

            guard let success = result?.raw?["success"].boolValue,
                success == true else {
                    if let errorMessage = result?.raw?["error"].string {
                        self?.showAlert(.errorMessage(errorMessage))
                    } else {
                        self?.showAlert(.errorUnknown)
                    }
                    sender.isEnabled = true
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
                    sender.isEnabled = true
                    self?.showAlert(.errorUnknown)
                }
            }
        }
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: FormTableViewDelegate

extension NewRoomViewController: FormTableViewDelegate {
    func updateDictValue(key: String, value: Any) {
        setValues[key] = value

        if key == "public room",
            let value = value as? Bool,
            let cellRoomName = referenceOfCells["room name"] as? TextFieldTableViewCell {

            if value {
                cellRoomName.imgLeftIcon.image = #imageLiteral(resourceName: "Hashtag")
            } else {
                cellRoomName.imgLeftIcon.image = #imageLiteral(resourceName: "Lock")
            }
        }
    }

    func getPreviousValue(key: String) -> Any? {
        return setValues[key]
    }
}

// MARK: UITableViewDelegate

extension NewRoomViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section].cells[indexPath.row]

        if let newChannelCell = data.cell.createCell(table: tableView, delegate: self, key: data.key),
            let newCell = newChannelCell as? UITableViewCell {

            referenceOfCells[data.key] = newChannelCell
            return newCell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(tableViewData[indexPath.section].cells[indexPath.row].cell.getClass().defaultHeight)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewData[section].name
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewData[section].footer
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let data = tableViewData[indexPath.section].cells[indexPath.row]
        referenceOfCells.removeValue(forKey: data.key)
    }
}

// MARK: UITableViewDataSource

extension NewRoomViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].cells.count
    }
}
