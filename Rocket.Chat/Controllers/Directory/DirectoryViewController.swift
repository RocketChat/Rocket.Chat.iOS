//
//  DirectoryViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 26/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

final class DirectoryViewController: BaseTableViewController {

    let viewModel = DirectoryViewModel()

    weak var filtersView: DirectoryFiltersView?

    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

    @IBOutlet weak var iconFiltering: UIImageView! {
        didSet {
            iconFiltering.image = viewModel.typeIcon
        }
    }

    @IBOutlet weak var labelFiltering: UILabel! {
        didSet {
            labelFiltering.text = viewModel.typeDescription
        }
    }

    @IBOutlet weak var iconFilteringDisclosure: UIImageView! {
        didSet {
            iconFilteringDisclosure.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        if navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = nil
        }

        setupSearchBar()
        setupHeaderViewGestures()
        setupTableViewCells()

        loadMoreData(reload: true)
    }

    func setupHeaderViewGestures() {
        if let headerView = tableView.tableHeaderView {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(userDidTappedHeaderView(_:)))
            headerView.addGestureRecognizer(gesture)
        }
    }

    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.isActive = false

        searchBar = searchController.searchBar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        self.searchController = searchController
        searchBar?.placeholder = localized("subscriptions.search")
        searchBar?.delegate = self
        searchBar?.applyTheme()
    }

    func setupTableViewCells() {
        tableView.register(DirectoryUserCell.nib, forCellReuseIdentifier: DirectoryUserCell.identifier)
        tableView.register(DirectoryChannelCell.nib, forCellReuseIdentifier: DirectoryChannelCell.identifier)
    }

    // MARK: Data Management

    func loadMoreData(reload: Bool = false) {
        let oldValues = viewModel.numberOfObjects

        if reload {
            let activity = UIActivityIndicatorView(style: .gray)
            let buttonActivity = UIBarButtonItem(customView: activity)
            activity.startAnimating()
            navigationItem.rightBarButtonItem = buttonActivity

            AnalyticsManager.log(event: Event.directory(
                searchType: viewModel.type.rawValue,
                workspace: viewModel.workspace.rawValue
            ))
        }

        viewModel.loadMoreObjects { [weak self] in
            guard let self = self else { return }

            if reload {
                self.navigationItem.rightBarButtonItem = nil
                self.tableView.reloadData()
                return
            }

            let newValues = self.viewModel.numberOfObjects
            var indexPaths: [IndexPath] = []

            for index in oldValues..<newValues {
                indexPaths.append(IndexPath(row: index, section: 0))
            }

            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths, with: .automatic)
            self.tableView.endUpdates()

            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: IBAction

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    @objc func userDidTappedHeaderView(_ gesture: UIGestureRecognizer) {
        if let filtersView = filtersView {
            filtersView.close()
            return
        }

        searchBar?.resignFirstResponder()

        filtersView = DirectoryFiltersView.showIn(self.view)
        filtersView?.delegate = self
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let filtersView = filtersView {
            filtersView.close()
            return
        }
    }

}

// MARK: UITableViewDataSource

extension DirectoryViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.type == .users {
            let user = viewModel.user(at: indexPath.row)
            return cellFor(user: user, at: indexPath)
        }

        let channel = viewModel.channel(at: indexPath.row)
        return cellFor(channel: channel, at: indexPath)
    }

    func cellFor(user: UnmanagedUser, at indexPath: IndexPath) -> DirectoryUserCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DirectoryUserCell.identifier, for: indexPath) as? DirectoryUserCell else {
            fatalError("cell could not be created")
        }

        cell.user = user
        return cell
    }

    func cellFor(channel: UnmanagedSubscription, at indexPath: IndexPath) -> DirectoryChannelCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DirectoryChannelCell.identifier, for: indexPath) as? DirectoryChannelCell else {
            fatalError("cell could not be created")
        }

        cell.channel = channel
        return cell
    }

}

// MARK: UITableViewDelegate

extension DirectoryViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfObjects - viewModel.pageSize / 2 {
            loadMoreData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.type == .users {
            let user = viewModel.user(at: indexPath.row)
            AppManager.openDirectMessage(username: user.username)
        }

        if viewModel.type == .channels {
            let channel = viewModel.channel(at: indexPath.row)
            AppManager.openRoom(name: channel.name, type: channel.type)
        }
    }

}

extension DirectoryViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let filtersView = filtersView {
            filtersView.close()
        }

        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" && !viewModel.query.isEmpty {
            search()
        }
    }

    func search() {
        viewModel.query = searchBar?.text ?? ""
        tableView.reloadData()
        loadMoreData(reload: true)
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        search()
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

}

extension DirectoryViewController: DirectoryFiltersViewDelegate {

    func userDidChangeFilterOption(selected: DirectoryRequestType) {
        viewModel.type = selected

        tableView.reloadData()

        iconFiltering.image = viewModel.typeIcon
        labelFiltering.text = viewModel.typeDescription

        loadMoreData(reload: true)
    }

}
