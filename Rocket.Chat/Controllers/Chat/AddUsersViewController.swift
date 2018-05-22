//
//  AddUsersViewController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class AddUsersViewData {
    var searchText: String = ""
    var subscription: Subscription?

    let pageSize = 50
    var currentPage = 0

    var showing: Int = 0
    var total: Int = 0

    var title: String = localized("chat.add_users.title")

    var isShowingAllUsers: Bool {
        return showing >= total
    }

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

                strongSelf.isLoadingMoreUsers = false
                completion?()
            case .error:
                Alert.defaultError.present()
            }
        }
    }
}

class AddUsersViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }

    var loaderCell: LoaderTableViewCell!
    var data = AddUsersViewData()

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
        refreshUsers()
    }

    func refreshUsers(searchText: String = "") {
        let data = AddUsersViewData()
        data.searchText = searchText
        data.subscription = self.data.subscription
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

    lazy var debouncedRefreshUsers = debounce(0.5) { [weak self] in
        self?.refreshUsers(searchText: self?.searchBar?.text ?? "")
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

// MARK: UITableView

extension AddUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard
            let roomId = data.subscription?.rid,
            let roomType = data.subscription?.type,
            let userId = data.user(at: indexPath.row).identifier,
            let api = API.current()
        else {
            return
        }

        alertYesNo(
            title: localized("chat.add_users.confirm.title"),
            message: localized("chat.add_users.confirm.message"),
            handler: { yes in
                guard yes else { return }

                let req = RoomInviteRequest(roomId: roomId, roomType: roomType, userId: userId)
                api.fetch(req, completion: { [weak self] response in
                    switch response {
                    case .resource(let resource):
                        
                        print(resource)
                    case .error:
                        break
                    }
                })
        })
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == data.users.count - data.pageSize/2 {
            loadMoreMembers()
        }
    }
}

extension AddUsersViewController: UITableViewDataSource {
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

// MARK: UISearchBar

extension AddUsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncedRefreshUsers()
    }
}
