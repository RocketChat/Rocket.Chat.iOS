//
//  SERoomsViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

final class SERoomsViewController: SEViewController {
    private var viewModel = SERoomsViewModel.emptyState

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        navigationItem.searchController = searchController
    }

    override func stateUpdated(_ state: SEState) {
        super.stateUpdated(state)

        viewModel = SERoomsViewModel(state: state)
        title = viewModel.title
        tableView.reloadData()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelShareExtension()
    }
}

// MARK: UISearchBarDelegate

extension SERoomsViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        store.dispatch(.setSearchRooms(.none))
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        store.dispatch(.setSearchRooms(.started))
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        store.dispatch(.setSearchRooms(.searching(searchText)))
    }
}

// MARK: UITableViewDataSource

extension SERoomsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.cellForRowAt(indexPath)

        let cell: UITableViewCell

        if let cellModel = cellModel as? SERoomCell {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellModel.reuseIdentifier)
            cell.textLabel?.text = cellModel.title
        } else if let cellModel = cellModel as? SEServerCell {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellModel.reuseIdentifier)
            cell.textLabel?.text = cellModel.title
            cell.detailTextLabel?.text = cellModel.detail
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellModel.reuseIdentifier)
        }

        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(section)
    }
}

// MARK: UITableViewDelegate

extension SERoomsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
