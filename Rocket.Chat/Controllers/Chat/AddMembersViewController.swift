//
//  AddMembersViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class AddMembersViewData {
    var searchText: String = ""
    var subscription: Subscription?

    let pageSize = 50
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String = localized("chat.users.list.title")

    var isShowingAllUsers: Bool = false

    var usersPages: [[User]] = []
    var users: FlattenCollection<[[User]]> {
        return usersPages.joined()
    }

    func user(at index: Int) -> User {
        return users[users.index(users.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreUsers = false
    func loadMoreUsers(completion: (() -> Void)? = nil) {
        if isLoadingMoreUsers { return }

        isLoadingMoreUsers = true

        let request = DirectoryRequest(text: searchText, type: .users)
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage*pageSize)]

        API.current()?.fetch(request, options: options) { [weak self] response in
            guard let strongSelf = self else { return }
            switch response {
            case .resource(let resource):
                strongSelf.showing += resource.count ?? 0
                strongSelf.total = resource.total ?? 0
                strongSelf.usersPages.append(resource.users)

                strongSelf.currentPage += 1

                strongSelf.title = "\(localized("chat.members.list.title")) (\(strongSelf.total))"
                strongSelf.isLoadingMoreUsers = false
                completion?()
            case .error:
                Alert.defaultError.present()
            }
        }
    }
}

class AddMembersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var loaderCell: LoaderTableViewCell!
    var data = AddMembersViewData()

    override func viewDidLoad() {
        super.viewDidLoad()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlDidPull), for: .valueChanged)

        tableView.refreshControl = refreshControl

        registerCells()

        if let cell = tableView.dequeueReusableCell(withIdentifier: LoaderTableViewCell.identifier) as? LoaderTableViewCell {
            self.loaderCell = cell
        }

        title = data.title
    }

    @objc func refreshControlDidPull(_ sender: UIRefreshControl) {
        let data = AddMembersViewData()
        data.loadMoreUsers { [weak self] in
            self?.data = data

            if self?.tableView?.refreshControl?.isRefreshing ?? false {
                self?.tableView?.refreshControl?.endRefreshing()
            }

            UIView.performWithoutAnimation {
                self?.tableView?.reloadData()
            }
        }
    }

    func loadMoreMembers() {
        data.loadMoreUsers { [weak self] in
            self?.title = self?.data.title

            if self?.tableView?.refreshControl?.isRefreshing ?? false {
                self?.tableView?.refreshControl?.endRefreshing()
            }

            UIView.performWithoutAnimation {
                self?.tableView?.reloadData()
            }
        }
    }

    func registerCells() {
        tableView.register(UINib(
            nibName: "MemberCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: MemberCell.identifier)

        tableView.register(UINib(
            nibName: "LoaderTableViewCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: LoaderTableViewCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadMoreMembers()

        guard let refreshControl = tableView.refreshControl else { return }
        tableView.refreshControl?.beginRefreshing()
        tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
    }
}

// MARK: TableView

extension AddMembersViewController: UITableViewDelegate {

}

extension AddMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.users.count + (data.isShowingAllUsers ? 0 : 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == data.users.count {
            return self.loaderCell
        }

        if let cell = tableView.dequeueReusableCell(withIdentifier: MemberCell.identifier) as? MemberCell {
            cell.data = MemberCellData(member: data.user(at: indexPath.row))
            return cell
        }

        return UITableViewCell(style: .default, reuseIdentifier: nil)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
