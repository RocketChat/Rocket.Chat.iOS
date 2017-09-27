//
//  NewChannelViewController.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 27/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class NewChannelViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate

extension NewChannelViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

// MARK: UITableViewDataSource

extension NewChannelViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
