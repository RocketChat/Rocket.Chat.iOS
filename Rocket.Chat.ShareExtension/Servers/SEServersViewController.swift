//
//  SEServersViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 2/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import Social

protocol SEServersViewDelegate {
    func serversViewController(_ serversViewController: SEServersViewController, didSelectServerCell serverCell: SEServerCell)
}

class SEServersViewController: UIViewController {
    var delegate: SEServersViewDelegate?

    let model = SEServersViewModel(serverCells: [
        SEServerCell(title: "open.rocket.chat", selected: true),
        SEServerCell(title: "cardoso.rocket.chat", selected: false)
    ])

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        update(model: model)
    }

    func update(model: SEServersViewModel) {
        title = model.title
        tableView.reloadData()
    }
}

extension SEServersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = model.cellForRowAt(indexPath)

        let cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCellDefault")

        cell.textLabel?.text = cellModel.title
        cell.accessoryType = cellModel.selected ? .checkmark : .none

        return cell
    }
}

extension SEServersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.serversViewController(self, didSelectServerCell: model.cellForRowAt(indexPath))
    }
}
