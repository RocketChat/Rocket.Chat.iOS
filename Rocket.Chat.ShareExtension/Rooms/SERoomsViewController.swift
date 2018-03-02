//
//  SERoomsViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

class SERoomsViewController: SEViewController {
    private var viewModel = SERoomsViewModel.emptyState

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let serversViewController = segue.destination as? SEServersViewController {
            serversViewController.delegate = self
        }
    }

    override func storeUpdated(_ store: SEStore) {
        super.storeUpdated(store)

        viewModel = SERoomsViewModel(store: store)
        title = viewModel.title
        tableView.reloadData()
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelShareExtension()
    }
}

extension SERoomsViewController: SEServersViewDelegate {
    func serversViewController(_ serversViewController: SEServersViewController, didSelectServerCell serverCell: SEServerCell) {
        navigationController?.popViewController(animated: true)
    }
}

extension SERoomsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = viewModel.cellForRowAt(indexPath)

        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCellDefault")

        cell.textLabel?.text = cellModel.title
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(section)
    }
}

extension SERoomsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SendSegue", sender: viewModel.cellForRowAt(indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
