//
//  DirectoryViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 26/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

final class DirectoryViewController: BaseViewController {

    let viewModel = DirectoryViewModel()

    weak var filtersView: DirectoryFiltersView?

    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.first != self {
            navigationItem.leftBarButtonItem = nil
        }

        setupSearchBar()
        setupHeaderViewGestures()
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

        filtersView = DirectoryFiltersView.showIn(self.view)
    }

}

extension DirectoryViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }

}
