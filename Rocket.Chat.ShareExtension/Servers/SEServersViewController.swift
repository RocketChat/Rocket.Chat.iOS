//
//  SEServersViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

final class SEServersViewController: SEViewController {
    private var viewModel = SEServersViewModel.emptyState

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(SEServerCell.self)
        }
    }

    override func stateUpdated(_ state: SEState) {
        super.stateUpdated(state)

        viewModel = SEServersViewModel(state: state)
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
        let cell = tableView.dequeue(SEServerCell.self, forIndexPath: indexPath)
        cell.cellModel = viewModel.cellForRowAt(indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.heightForRowAt(indexPath))
    }
}

extension SEServersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath)
    }
}
