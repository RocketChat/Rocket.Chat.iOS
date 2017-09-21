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

    var showMoreButtonTitle = "SHOW MORE"
    var isShowingAllMembers: Bool {
        return showing >= total
    }

    var membersPages: [[API.User]] = []
    var members: FlattenCollection<[[API.User]]> {
        return membersPages.joined()
    }

    func member(at index: Int) -> API.User {
        return members[members.index(members.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreMembers = false
    func loadMoreMembers(completion: (() -> Void)? = nil) {
        if isLoadingMoreMembers { return }

        if let subscription = subscription {
            isLoadingMoreMembers = true
            API.shared.fetch(ChannelMembersRequest(roomId: subscription.rid), options: .paginated(count: pageSize, offset: currentPage*pageSize)) { result in
                self.showing += result?.count ?? 0
                self.total = result?.total ?? 0
                if let members = result?.members {
                    self.membersPages.append(members.flatMap { $0 })
                }

                self.currentPage += 1

                self.isLoadingMoreMembers = false
                completion?()
            }
        }
    }
}

class MembersListViewController: UIViewController {
    @IBOutlet weak var membersTableView: UITableView!
    var buttonCell: ButtonCell!

    var data = MembersListViewData()

    func loadMoreMembers() {
        self.buttonCell.button.isEnabled = false
        data.loadMoreMembers {
            DispatchQueue.main.async {
                self.buttonCell.button.isEnabled = true
                self.membersTableView.reloadData()
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

        membersTableView.register(UINib(
            nibName: "ButtonCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ButtonCell.identifier)

        if let cell = membersTableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier) as? ButtonCell {
            cell.button.setTitle(data.showMoreButtonTitle, for: UIControlState.normal)
            cell.press = self.loadMoreMembers
            self.buttonCell = cell
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMoreMembers()
    }
}

// MARK: TableView

extension MembersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.members.count + (data.isShowingAllMembers ? 0 : 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == data.members.count {
            return self.buttonCell
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier) as? MemberCell {
            cell.data = MemberCellData(member: data.member(at: indexPath.row))
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension MembersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == data.members.count {
            loadMoreMembers()
        }
    }
}
