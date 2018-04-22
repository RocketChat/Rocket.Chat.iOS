//
//  BlockedUsersListViewController.swift
//  Rocket.Chat
//
//  Created by Hrayr Yeghiazaryan on 26.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

class BlockedUsersListViewController: BaseViewController {

    fileprivate let memberCellHeight: CGFloat = 50

    // UI-elements

    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var viewEmptyList: UIView!
    @IBOutlet weak var labelEmptyList: UILabel!

    var realm: Realm? = Realm.current
}

// MARK: ViewController

extension BlockedUsersListViewController {
    override func viewDidLoad() {
        registerCells()
        self.labelEmptyList.text = localized("blocked.list.empty.title")
        title = localized("blocked.users.title")
        self.membersTableView.separatorStyle = .none
    }

    func registerCells() {
        membersTableView.register(UINib(
            nibName: "MemberCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: MemberCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showEmptyStateIfNeeded()
    }
}

// MARK: TableViewDataSourse

extension BlockedUsersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageManager.blockedUsersList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier) as? MemberCell {

            guard let user = User.find(withIdentifier: MessageManager.blockedUsersList[indexPath.row]) else { return cell }
            cell.data = MemberCellData(member: user)
            guard user.name != nil else {
                cell.nameLabel.text = user.username
                return cell
            }
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return memberCellHeight
    }
}

// MARK: TableViewDelegate

extension BlockedUsersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let user = User.find(withIdentifier: MessageManager.blockedUsersList[indexPath.row]) else { return }
        guard let username = user.username else { return }
        blockedUserActions(username, user)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let user = User.find(withIdentifier: MessageManager.blockedUsersList[indexPath.row]) else { return }
        if editingStyle == .delete {
            MessageManager.unblockMessagesFrom(user, completion: {
                UIView.performWithoutAnimation {
                    self.showEmptyStateIfNeeded()
                    self.membersTableView?.reloadData()
                }
            })
        }
    }
}

// MARK: Blocked users' actions

extension BlockedUsersListViewController {
    func blockedUserActions(_ username: String, _ user: User) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: localized("chat.member.open.profile.title"), style: .default, handler: { _ in
            AppManager.openDirectMessage(username: username) {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: localized("chat.member.unblock.title"), style: .destructive, handler: { _ in
            MessageManager.unblockMessagesFrom(user, completion: {
                UIView.performWithoutAnimation {
                    self.showEmptyStateIfNeeded()
                    self.membersTableView?.reloadData()
                }
            })
        }))
        alert.addAction(UIAlertAction(title: localized("global.cancel"), style: .cancel, handler: nil))

        if let presenter = alert.popoverPresentationController {
            presenter.sourceView = view
            presenter.sourceRect = view.bounds
        }
        present(alert, animated: true, completion: nil)
    }

    // If we don't have blocked users the emptyView won't be hidden

    func showEmptyStateIfNeeded() {
        if MessageManager.blockedUsersList.count == 0 {
            self.viewEmptyList.isHidden = false
        } else {
            self.viewEmptyList.isHidden = true
        }
    }
}
