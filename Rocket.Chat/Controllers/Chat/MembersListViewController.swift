//
//  MembersListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class MembersListViewData {
    var subscription: Subscription?

    let pageSize = 100
    var currentPage = 0

    var showing: Int = 0
    var online: Int = 0
    var total: Int = 0

    var description: String {
        return "Showing: \(showing), Online: \(online), Total: \(total) users"
    }

    var membersPages: [[API.User]] = []
    var members: FlattenCollection<[[API.User]]> {
        return membersPages.joined()
    }

    func member(at index: Int) -> API.User {
        return members[members.index(members.startIndex, offsetBy: index)]
    }

    func loadMoreMembers(completion: (() -> Void)? = nil) {
        if let subscription = subscription {
            API.shared.fetch(ChannelMembersRequest(roomId: subscription.rid), options: .paginated(count: pageSize, offset: currentPage)) { result in
                self.showing += result?.count ?? 0
                self.total = result?.total ?? 0
                if let members = result?.members {
                    self.membersPages.append(members.flatMap { $0 })
                }

                completion?()
            }
        }
    }
}

class MembersListViewController: UIViewController {
    @IBOutlet weak var membersTableView: UITableView!

    var data = MembersListViewData()
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

        data.loadMoreMembers {
            DispatchQueue.main.async {
                self.membersTableView.reloadData()
            }
        }
    }
}

// MARK: TableView

extension MembersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.members.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier) as? MemberCell {
            cell.data = MemberCellData(member: data.member(at: indexPath.row))
            return cell
        }

        return UITableViewCell()
    }
}
