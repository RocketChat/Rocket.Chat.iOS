//
//  MembersListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class MembersListViewController: UIViewController {
    @IBOutlet weak var membersTableView: UITableView!

    var subscription: Subscription?
    var usernames: [String] = []

    func updateUsers() {
        if let subscription = subscription {
            API.shared.fetch(ChannelInfoRequest(roomId: subscription.rid)) { result in
                if let usernames = result?.usernames {
                    self.usernames = usernames
                    DispatchQueue.main.async {
                        self.membersTableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: ViewController
extension MembersListViewController {
    override func viewDidLoad() {
        membersTableView.register(UINib(
            nibName: "MemberCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: MemberCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUsers()
    }
}

// MARK: TableView

extension MembersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier) as? MemberCell {
            cell.nameLabel.text = usernames[indexPath.row]
            return cell
        }

        return UITableViewCell()
    }
}
