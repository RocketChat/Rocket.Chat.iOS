//
//  SEServersViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

protocol SEServersViewDelegate: class {
    func serversViewController(_ serversViewController: SEServersViewController, didSelectServerCell serverCell: SEServerCell)
}

class SEServersViewController: SEViewController {
    weak var delegate: SEServersViewDelegate?

    private var viewModel = SEServersViewModel.emptyState

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    override func storeUpdated(_ store: SEStore) {
        super.storeUpdated(store)

        viewModel = SEServersViewModel(store: store)
        title = viewModel.title
        tableView.reloadData()
    }
}

extension SEServersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.cellForRowAt(indexPath)

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCellDefault")

        cell.textLabel?.text = cellModel.title
        cell.detailTextLabel?.text = cellModel.detail
        cell.accessoryType = cellModel.selected ? .checkmark : .none

        return cell
    }
}

extension SEServersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        store.selectedServerIndex = indexPath.row
        delegate?.serversViewController(self, didSelectServerCell: viewModel.cellForRowAt(indexPath))
    }
}
