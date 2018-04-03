//
//  MembersListViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

protocol MembersListDelegate: class {
    func membersList(_ controller: MembersListViewController, didSelectUser user: User)
}

class MembersListViewData {
    var subscription: Subscription?

    let pageSize = 50
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String = localized("chat.members.list.title")

    var isShowingAllMembers: Bool {
        return showing >= total
    }

    var membersPages: [[User]] = []
    var members: FlattenCollection<[[User]]> {
        return membersPages.joined()
    }

    func member(at index: Int) -> User {
        return members[members.index(members.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreMembers = false
    func loadMoreMembers(completion: (() -> Void)? = nil) {
        if isLoadingMoreMembers { return }

        if let subscription = subscription {
            isLoadingMoreMembers = true

            let request = SubscriptionMembersRequest(roomId: subscription.rid, type: subscription.type)
            let options = APIRequestOptions.paginated(count: pageSize, offset: currentPage*pageSize)

            API.current()?.fetch(request, options: options, succeeded: { result in
                self.showing += result.count ?? 0
                self.total = result.total ?? 0
                if let members = result.members {
                    self.membersPages.append(members.flatMap { $0 })
                }

                self.currentPage += 1

                self.title = "\(localized("chat.members.list.title")) (\(self.total))"
                self.isLoadingMoreMembers = false
                completion?()
            }, errored: { _ in
                Alert.defaultError.present()
            })
        }
    }
}

class MembersListViewController: BaseViewController {
    @IBOutlet weak var membersTableView: UITableView!
    var loaderCell: LoaderTableViewCell!

    var data = MembersListViewData()

    weak var delegate: MembersListDelegate?

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        let data = MembersListViewData()
        data.subscription = self.data.subscription
        data.loadMoreMembers { [weak self] in
            self?.data = data

            DispatchQueue.main.async {
                if self?.membersTableView?.refreshControl?.isRefreshing ?? false {
                    self?.membersTableView?.refreshControl?.endRefreshing()
                }

                UIView.performWithoutAnimation {
                    self?.membersTableView?.reloadData()
                }
            }
        }
    }

    func loadMoreMembers() {
        data.loadMoreMembers { [weak self] in
            DispatchQueue.main.async {
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
}

// MARK: ViewController
extension MembersListViewController {
    override func viewDidLoad() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)

        membersTableView.refreshControl = refreshControl

        registerCells()

        if let cell = membersTableView.dequeueReusableCell(withIdentifier: LoaderTableViewCell.identifier) as? LoaderTableViewCell {
            self.loaderCell = cell
        }

        title = data.title
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

        loadMoreMembers()

        guard let refreshControl = membersTableView.refreshControl else { return }
        membersTableView.refreshControl?.beginRefreshing()
        membersTableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
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

extension MembersListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let user = data.member(at: indexPath.row)
        delegate?.membersList(self, didSelectUser: user)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == data.members.count - data.pageSize/2 {
            loadMoreMembers()
        }
    }
}
