//
//  LegalTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 13/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SafariServices

class LegalTableViewController: UITableViewController {

    @IBOutlet weak var termsOfUseLabel: UILabel! {
        didSet {
            termsOfUseLabel.text = localized("auth.login.agree_termsofservice")
        }
    }

    @IBOutlet weak var privacyPolicyLabel: UILabel! {
        didSet {
            privacyPolicyLabel.text = localized("auth.login.agree_privacypolicy")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let nav = navigationController as? BaseNavigationController {
            nav.setGrayTheme()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    @IBAction func close() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

extension LegalTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let serverURL = SocketManager.sharedInstance.serverURL else {
            return
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = serverURL.host

        if var newURL = components.url {
            switch indexPath.row {
            case 0:
                newURL = newURL.appendingPathComponent("terms-of-service")
            case 1:
                newURL = newURL.appendingPathComponent("privacy-policy")
            default:
                return
            }

            let controller = SFSafariViewController(url: newURL)
            present(controller, animated: true, completion: nil)
        }
    }

}
