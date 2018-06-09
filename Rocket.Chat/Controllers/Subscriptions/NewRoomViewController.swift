//
//  NewRoomViewController.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

final class NewRoomViewController: BaseViewController {

    override func awakeFromNib() {
        super.awakeFromNib()
        title = localized("new_room.title")
        navigationItem.rightBarButtonItem?.title = localized("new_room.buttons.create")
    }

    static var user: User? {
        return AuthManager.currentUser()
    }

    let tableViewData: [SectionForm] = [
        SectionForm(
            name: nil,
            footer: nil,
            cells: [
                createPublicChannelSwitch(
                    allowPublic: user?.hasPermission(.createPublicChannels) ?? false,
                    allowPrivate: user?.hasPermission(.createPublicChannels) ?? false
                ),
                FormCell(
                    cell: .check(title: localized("new_room.cell.read_only.title"), description: localized("new_room.cell.read_only.description")),
                    key: "read only room",
                    defaultValue: false,
                    enabled: true
                )
            ]
        ),
        SectionForm(
            name: localized("new_room.group.channel.name"),
            footer: nil,
            cells: [
                FormCell(
                    cell: .textField(placeholder: localized("new_room.cell.channel_name.title"), icon: #imageLiteral(resourceName: "Hashtag")),
                    key: "room name",
                    defaultValue: [],
                    enabled: true
                )
            ]
        )
    ]

    static func createPublicChannelSwitch(allowPublic: Bool, allowPrivate: Bool) -> FormCell {
        var description: String = ""
        if allowPublic && allowPrivate {
            description = localized("new_room.cell.public_channel.description")
        } else if allowPublic {
            description = localized("new_room.cell.public_channel.description.public_only")
        } else if allowPrivate {
            description = localized("new_room.cell.public_channel.description.private_only")
        }

        return FormCell(
            cell: .check(title: localized("new_room.cell.public_channel.title"), description: description),
            key: "public room",
            defaultValue: allowPublic,
            enabled: allowPublic && allowPrivate
        )
    }

    var referenceOfCells: [String: FormTableViewCellProtocol] = [:]
    lazy var setValues: [String: Any] = {
        return tableViewData.reduce([String: Any]()) { (dict, entry) in
            var ndict = dict
            entry.cells.forEach { ndict[$0.key] = $0.defaultValue }
            return ndict
        }
    }()

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.keyboardDismissMode = .interactive

            CheckTableViewCell.registerCell(for: tableView)
            TextFieldTableViewCell.registerCell(for: tableView)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillHide, object: nil)

        let user = NewRoomViewController.user
        let createPrivate = user?.hasPermission(.createPrivateChannels) ?? false
        let createPublic = user?.hasPermission(.createPublicChannels) ?? false

        if !createPrivate && !createPublic {
            let title = localized("alert.authorization_error.title")
            let message = localized("alert.authorization_error.create_channel.description")

            alert(title: title, message: message) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    fileprivate func showErrorAlert(_ errorMessage: String?) {
        let errorMessage = errorMessage ?? localized("error.socket.default_error.message")

        Alert(
            title: localized("error.socket.default_error.title"),
            message: errorMessage
        ).present()
    }

    @IBAction func buttonCreateDidPressed(_ sender: UIButton) {
        guard
            let roomName = setValues["room name"] as? String,
            let publicRoom = setValues["public room"] as? Bool,
            let readOnlyRoom = setValues["read only room"] as? Bool
        else {
            return
        }

        sender.isEnabled = false

        let roomType: RoomCreateType = publicRoom ? .channel : .group
        executeRequestCreateRoom(roomName: roomName, roomType: roomType, members: [], readOnlyRoom: readOnlyRoom) { [weak self] success, errorMessage in
            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.showErrorAlert(errorMessage)
                sender.isEnabled = true
            }
        }
    }

    fileprivate func executeRequestCreateRoom(roomName: String, roomType: RoomCreateType, members: [String], readOnlyRoom: Bool, completion: @escaping (Bool, String?) -> Void) {
        let request = RoomCreateRequest(
            name: roomName,
            type: roomType,
            members: members,
            readOnly: readOnlyRoom
        )

        API.current()?.fetch(request) { response in
            switch response {
            case .resource(let resource):
                guard
                    let success = resource.success,
                    let name = resource.name, success == true,
                    let auth = AuthManager.isAuthenticated()
                else {
                    completion(false, resource.error)
                    return
                }

                SubscriptionManager.updateSubscriptions(auth) {
                    if let newRoom = Realm.current?.objects(Subscription.self).filter("name == '\(name)' && privateType != 'd'").first {
                        AppManager.open(room: newRoom)
                        completion(true, nil)
                    } else {
                        completion(false, nil)
                    }
                }
            case .error:
                Alert.defaultError.present()
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

    func updateTable(key: String) {
        tableView.beginUpdates()
        tableView.endUpdates()

        var section = 0
        for sectionForm in tableViewData {
            var row = 0
            for cell in sectionForm.cells {
                if cell.key == key {
                    tableView.scrollToRow(at: IndexPath(row: row, section: section), at: .none, animated: true)
                    return
                }
                row += 1
            }
            section += 1
        }
    }
}

// MARK: UITableViewDelegate

extension NewRoomViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section].cells[indexPath.row]

        if let newChannelCell = data.cell.createCell(table: tableView, delegate: self, key: data.key, enabled: data.enabled),
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

// MARK: Update cell position when the keyboard will show/hide

extension NewRoomViewController {
    func getTableViewInsets(keyboardHeight: CGFloat) -> UIEdgeInsets? {
        guard let window = UIApplication.shared.delegate?.window as? UIWindow else { return nil }
        guard let tableViewFrame = tableView.superview?.convert(tableView.frame, to: window) else { return nil }

        let bottomInset = keyboardHeight - (window.frame.height - tableViewFrame.height - tableViewFrame.origin.y)

        return UIEdgeInsets(
            top: tableView.contentInset.top,
            left: tableView.contentInset.left,
            bottom: bottomInset,
            right: tableView.contentInset.right
        )
    }

    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let animationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        guard let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardHeight = keyboardFrame.cgRectValue.height
        guard let contentInsets = getTableViewInsets(keyboardHeight: keyboardHeight) else { return }

        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.tableView.contentInset = contentInsets
                self.tableView.scrollIndicatorInsets = contentInsets
            }, completion: { _ -> Void in
                guard let contentInsets = self.getTableViewInsets(keyboardHeight: keyboardHeight) else { return }

                self.tableView.contentInset = contentInsets
                self.tableView.scrollIndicatorInsets = contentInsets
            }
        )
    }
}
