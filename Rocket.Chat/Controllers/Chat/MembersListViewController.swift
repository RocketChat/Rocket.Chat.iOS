//
//  MembersListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

class MembersListViewData {
    var subscription: Subscription?

    let pageSize = 50
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String {
        return String(format: localized("chat.members.list.title"), total)
    }

    var isShowingAllMembers: Bool {
        return showing >= total
    }

    var canInviteUsers: Bool {
        return subscription?.canInviteUsers() ?? false
    }

    var membersPages: [[UnmanagedUser]] = []
    var members: FlattenCollection<[[UnmanagedUser]]> {
        return membersPages.joined()
    }

    func member(at index: Int) -> UnmanagedUser {
        return members[members.index(members.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreMembers = false
    func loadMoreMembers(completion: (() -> Void)? = nil) {
        if isLoadingMoreMembers { return }

        if let subscription = subscription {
            isLoadingMoreMembers = true

            let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage*pageSize)]
            let client = API.current()?.client(SubscriptionsClient.self)

            client?.fetchMembersList(subscription: subscription, options: options) { [weak self] response, users in
                guard
                    let self = self,
                    let users = users,
                    case let .resource(resource) = response
                else {
                    return Alert.defaultError.present()
                }

                self.membersPages.append(users)

                self.showing += resource.count ?? 0
                self.total = resource.total ?? 0
                self.currentPage += 1

                self.isLoadingMoreMembers = false

                completion?()
            }
        }
    }
}

class MembersListViewController: BaseViewController {
    @IBOutlet weak var membersTableView: UITableView!
    var loaderCell: LoaderTableViewCell!

    var data = MembersListViewData() {
        didSet {
            UIView.performWithoutAnimation {
                membersTableView?.reloadData()
            }

            title = data.title
        }
    }

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        refreshMembers()
    }

    func refreshMembers() {
        let data = MembersListViewData()
        data.subscription = self.data.subscription
        data.loadMoreMembers { [weak self] in
            self?.data = data

            if self?.membersTableView?.refreshControl?.isRefreshing ?? false {
                self?.membersTableView?.refreshControl?.endRefreshing()
            }
        }
    }

    func loadMoreMembers() {
        data.loadMoreMembers { [weak self] in
            self?.title = self?.data.title

            if self?.membersTableView?.refreshControl?.isRefreshing ?? false {
                self?.membersTableView?.refreshControl?.endRefreshing()
            }

            UIView.performWithoutAnimation {
                self?.membersTableView?.reloadData()
            }
        }
    }
}

// MARK: ViewController
extension MembersListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)

        membersTableView.refreshControl = refreshControl

        registerCells()

        if let cell = membersTableView.dequeueReusableCell(withIdentifier: LoaderTableViewCell.identifier) as? LoaderTableViewCell {
            self.loaderCell = cell
        }

        title = data.title

        if data.canInviteUsers {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(inviteUsersButtonPressed(sender:)))
        }
    }

    @objc func inviteUsersButtonPressed(sender: Any) {
        performSegue(withIdentifier: "toAddUsers", sender: self)
    }

    func registerCells() {
        membersTableView.register(UINib(
            nibName: "MemberCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: MemberCell.identifier)

        membersTableView.register(UINib(
            nibName: "LoaderTableViewCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: LoaderTableViewCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refreshMembers()

        membersTableView.refreshControl?.beginRefreshing()
    }
}

// MARK: Prepare for Segue
extension MembersListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let addUsers = segue.destination as? AddUsersViewController {
            addUsers.data.subscription = data.subscription
        }
    }
}

// MARK: TableView

extension MembersListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.members.count + (data.isShowingAllMembers ? 0 : 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == data.members.count {
            return self.loaderCell
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

extension MembersListViewController: UITableViewDelegate, UserActionSheetPresenter {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let user = data.member(at: indexPath.row)
        let subscription = data.subscription
        let rect = tableView.rectForRow(at: indexPath)

        guard let managed = user.managedObject else {
            return
        }

        presentActionSheetForUser(
            managed,
            subscription: subscription,
            source: (tableView, rect)
        ) { [weak self] action in
            if case .remove = action {
                self?.refreshMembers()
            }
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == data.members.count - data.pageSize/2 {
            loadMoreMembers()
        }
    }
}
