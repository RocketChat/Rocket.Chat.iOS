//
//  StatusTableViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 23/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class StatusTableViewController: UITableViewController {

    let viewModel = StatusViewModel()

    @IBOutlet weak var labelOnline: UILabel! {
        didSet {
            labelOnline.text = viewModel.statusOnline
        }
    }

    @IBOutlet weak var labelAway: UILabel! {
        didSet {
            labelAway.text = viewModel.statusAway
        }
    }

    @IBOutlet weak var labelBusy: UILabel! {
        didSet {
            labelBusy.text = viewModel.statusBusy
        }
    }

    @IBOutlet weak var labelInvisible: UILabel! {
        didSet {
            labelInvisible.text = viewModel.statusInvisible
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if indexPath.row == viewModel.currentStatusIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let status = viewModel.status(for: indexPath.row)
        UserManager.setUserStatus(status: status) { _ in }
        viewModel.user?.updateStatus(status: status)

        navigationController?.popViewController(animated: true)
    }

}
