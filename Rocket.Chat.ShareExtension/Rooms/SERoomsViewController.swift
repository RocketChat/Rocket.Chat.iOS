//
//  SERoomsViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

class SERoomsViewController: UIViewController {
    private var viewModel = SERoomsViewModel(title: "open.rocket.chat", sections: [
        SERoomsSection(type: .favorites, roomCells: [
            SERoomCell(title: "@matheus.cardoso"),
            SERoomCell(title: "#general"),
            SERoomCell(title: "#important")
            ]),
        SERoomsSection(type: .channels, roomCells: [
            SERoomCell(title: "#general")
            ]),
        SERoomsSection(type: .groups, roomCells: [
            SERoomCell(title: "#ios-dev-internal"),
            SERoomCell(title: "#important")
            ]),
        SERoomsSection(type: .directMessages, roomCells: [
            SERoomCell(title: "@matheus.cardoso"),
            SERoomCell(title: "@rafael.kellermann"),
            SERoomCell(title: "@filipe.alvarenga"),
            SERoomCell(title: "@rocket.chat")
            ])
        ])

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

    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }

    func updateView(newViewModel: SERoomsViewModel? = nil) {
        if let newViewModel = newViewModel {
            viewModel = newViewModel
        }

        title = viewModel.title
        tableView.reloadData()
    }
}

extension SERoomsViewController: SEServersViewDelegate {
    func serversViewController(_ serversViewController: SEServersViewController, didSelectServerCell serverCell: SEServerCell) {
        updateView(newViewModel: viewModel.withTitle(serverCell.title))
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
