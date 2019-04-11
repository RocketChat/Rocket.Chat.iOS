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

    var usersPages: [[UnmanagedUser]] = []
    var users: FlattenCollection<[[UnmanagedUser]]> {
        return usersPages.joined()
    }

    func user(at index: Int) -> UnmanagedUser {
        return users[users.index(users.startIndex, offsetBy: index)]
    }

    private var isLoadingMoreUsers = false
    func loadMoreUsers(completion: (() -> Void)? = nil) {
        if isLoadingMoreUsers { return }

        isLoadingMoreUsers = true

        let request = DirectoryRequest(query: searchText, type: .users, workspace: .all)
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage*pageSize)]

        API.current()?.fetch(request, options: options) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .resource(let resource):
                self.showing += resource.count ?? 0
                self.total = resource.total ?? 0
                self.usersPages.append(resource.users)

                self.currentPage += 1

                self.isLoadingMoreUsers = false
                completion?()
            case .error:
                Alert.defaultError.present()
            }
        }
    }
}

class AddUsersViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }

    var searchBar: UISearchBar?

    var loaderCell: LoaderTableViewCell!
    var data = AddUsersViewData()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()

        if let cell = tableView.dequeueReusableCell(withIdentifier: LoaderTableViewCell.identifier) as? LoaderTableViewCell {
            self.loaderCell = cell
        }

        setupSearchBar()

        title = data.title
    }

    func refreshUsers(searchText: String = "") {
        searchBar?.textField?.startIndicatingActivity()

        let data = AddUsersViewData()
        data.searchText = searchText
        data.subscription = self.data.subscription
        data.loadMoreUsers { [weak self] in
            self?.data = data

            UIView.performWithoutAnimation {
                self?.tableView?.reloadData()
            }

            self?.searchBar?.textField?.stopIndicatingActivity()
        }
    }

    lazy var debouncedRefreshUsers = debounce(0.5) { [weak self] in
        self?.refreshUsers(searchText: self?.searchBar?.text ?? "")
    }

    func loadMoreMembers() {
        searchBar?.textField?.startIndicatingActivity()

        data.loadMoreUsers { [weak self] in
            self?.title = self?.data.title

            UIView.performWithoutAnimation {
                self?.tableView?.reloadData()
            }

            self?.searchBar?.textField?.stopIndicatingActivity()
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
    }
}

// MARK: UITableView

extension AddUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = data.user(at: indexPath.row)

        guard
            let roomId = data.subscription?.rid,
            let roomType = data.subscription?.type,
            let roomName = data.subscription?.displayName(),
            let api = API.current()
        else {
            return
        }

        let message = String(format: localized("chat.add_users.confirm.message"), user.displayName, roomName)

        let controller: UIViewController
        if let presentedViewController = presentedViewController {
            controller = presentedViewController
        } else {
            controller = self
        }

        controller.alertYesNo(
            title: localized("chat.add_users.confirm.title"),
            message: message,
            handler: { yes in
                tableView.deselectRow(at: indexPath, animated: true)

                guard yes else { return }

                let req = RoomInviteRequest(roomId: roomId, roomType: roomType, userId: user.identifier)
                api.fetch(req) { [weak self] response in
                    switch response {
                    case .resource(let resource):
                        if let error = resource.error {
                            Alert(title: localized("global.error"), message: error).present()
                        } else {
                            self?.presentedViewController?.dismiss(animated: true, completion: nil)
                            self?.navigationController?.popViewController(animated: true)
                        }
                    case .error:
                        break
                    }
                }
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

// MARK: SearchBar

extension AddUsersViewController {
    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        navigationController?.navigationBar.prefersLargeTitles = false

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchBar = searchController.searchBar
        searchBar?.placeholder = localized("subscriptions.search")
        searchBar?.delegate = self
    }
}

// MARK: UISearchBarDelegate

extension AddUsersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debouncedRefreshUsers()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        debouncedRefreshUsers()
    }
}
