//
//  SettingsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import SafariServices

class SettingsViewController: UITableViewController {

    @IBOutlet weak var labelVersion: UILabel! {
        didSet {
            guard let info = Bundle.main.infoDictionary else { return }
            guard let version = info["CFBundleShortVersionString"] as? String else { return }
            guard let build = info["CFBundleVersion"] as? String else { return }
            labelVersion.text = "Version: \(version) (\(build))"
        }
    }

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url: URL?

        if indexPath.row == 0 {
            url = URL(string: "https://rocket.chat")
        } else if indexPath.row == 1 {
            url = URL(string: "https://rocket.chat/contact")
        } else if indexPath.row == 2 {
            url = URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")
        }

        if let url = url {
            let controller = SFSafariViewController(url: url)
            navigationController?.pushViewController(controller, animated: true)
        }
    }

}
