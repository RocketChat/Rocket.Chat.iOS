//
//  SettingsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SafariServices

final class SettingsViewController: UITableViewController {

    private let viewModel = SettingsViewModel()

    @IBOutlet weak var labelVersion: UILabel! {
        didSet {
            labelVersion.text = viewModel.formattedVersion
        }
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = viewModel.settingsURL(atIndex: indexPath.row) else { return }

        let controller = SFSafariViewController(url: url)
        navigationController?.pushViewController(controller, animated: true)
    }
}
