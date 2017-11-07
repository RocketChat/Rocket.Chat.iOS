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
            footer: localized("new_room.group.channel.footer"),
            cells: [
                FormCell(
                    cell: .textField(placeholder: localized("new_room.cell.channel_name.title"), icon: #imageLiteral(resourceName: "Hashtag")),
                    key: "room name",
                    defaultValue: "",
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

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        CheckTableViewCell.registerCell(for: tableView)
        TextFieldTableViewCell.registerCell(for: tableView)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillHide, object: nil)

        let user = NewRoomViewController.user
        let createPrivate = user?.hasPermission(.createPrivateChannels) ?? false
        let createPublic = user?.hasPermission(.createPublicChannels) ?? false

        if !createPrivate && !createPublic {
            alert(title: localized("alert.authorization_error.title"),
                  message: localized("alert.authorization_error.create_channel.description")) { _ in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func showErrorAlert(_ errorMessage: String?) {
        let errorMessage = errorMessage ?? localized("error.socket.default_error_message")

        let alert = UIAlertController(
            title: localized("error.socket.default_error_title"),
            message: errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: localized("global.ok"), style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func buttonCreateDidPressed(_ sender: UIButton) {
        guard let roomName = setValues["room name"] as? String else { return }
        guard let publicRoom = setValues["public room"] as? Bool else { return }
        guard let readOnlyRoom = setValues["read only room"] as? Bool else { return }

        let roomType: SubscriptionCreateType
        if publicRoom {
            roomType = .channel
        } else {
            roomType = .group
        }

        sender.isEnabled = false
        executeRequestCreateRoom(roomName: roomName, roomType: roomType, readOnlyRoom: readOnlyRoom) { [weak self] success, errorMessage in

            if success {
                self?.dismiss(animated: true, completion: nil)
            } else {
                self?.showErrorAlert(errorMessage)
                sender.isEnabled = true
            }
        }
    }

    fileprivate func executeRequestCreateRoom(roomName: String, roomType: SubscriptionCreateType, readOnlyRoom: Bool, completion: @escaping (Bool, String?) -> Void) {
        API.shared.fetch(SubscriptionCreateRequest(name: roomName, type: roomType, readOnly: readOnlyRoom)) { result in

            guard let success = result?.success, success == true else {
                    completion(false, result?.error)
                    return
            }

            guard let auth = AuthManager.isAuthenticated() else { return }

            SubscriptionManager.updateSubscriptions(auth) { _ in
                if let newRoom = Realm.shared?.objects(Subscription.self).filter("name == '\(roomName)' && privateType != 'd'").first {

                    let controller = ChatViewController.shared
                    controller?.subscription = newRoom

                    completion(true, nil)
                } else {
                    completion(false, nil)
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
