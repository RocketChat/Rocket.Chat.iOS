//
//  WebBrowserTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class WebBrowserTableViewController: UITableViewController {

    let browserCellIdentifier = "WebBrowserCell"
    let browsers: [WebBrowserApp] = [.safari, .inAppSafari, .chrome].filter { $0.isInstalled }
    var updateDefaultWebBrowser: (() -> Void)?

    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: UITableViewDataSource

extension WebBrowserTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return browsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let browser = browsers[indexPath.row]
        let browserCell = tableView.dequeueReusableCell(withIdentifier: browserCellIdentifier, for: indexPath)
        browserCell.textLabel?.text = browser.name
        browserCell.accessoryType = browser == WebBrowserManager.browser ? .checkmark : .none

        return browserCell
    }

}

// MARK: UITableViewDelegate

extension WebBrowserTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard
            let indexOfSelectedBrowser = browsers.index(of: WebBrowserManager.browser),
            let selectedCell = tableView.cellForRow(at: IndexPath(row: indexOfSelectedBrowser, section: 0))
        else {
            return
        }

        if indexOfSelectedBrowser == indexPath.row {
            navigationController?.popViewController(animated: true)
            return
        }

        WebBrowserManager.set(defaultBrowser: browsers[indexPath.row])
        updateDefaultWebBrowser?()

        let newSelectedCell = tableView.cellForRow(at: indexPath)
        newSelectedCell?.accessoryType = .checkmark
        selectedCell.accessoryType = .none

        navigationController?.popViewController(animated: true)
    }

}
