//
//  ChannelInfoViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChannelInfoViewController: BaseViewController {

    var tableViewData: [[ChannelInfoCellProtocol.Type]] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var subscription: Subscription! {
        didSet {
            let channelInfoData = [
                ChannelInfoDetailCell.self,
                ChannelInfoDetailCell.self,
                ChannelInfoDetailCell.self,
                ChannelInfoDetailCell.self
            ]

            if subscription.type == .directMessage {
                tableViewData = [[
                    ChannelInfoUserCell.self
                ], channelInfoData]
            } else {
                tableViewData = [[
                    ChannelInfoBasicCell.self,
                    ChannelInfoDescriptionCell.self,
                    ChannelInfoDescriptionCell.self
                ], channelInfoData]
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: Cells

extension ChannelInfoViewController {


}

// MARK: UITableViewDelegate

extension ChannelInfoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = tableViewData[indexPath.section][indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.identifier) ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = tableViewData[indexPath.section][indexPath.row]
        return CGFloat(cellType.defaultHeight)
    }

}

// MARK: UITableViewDataSource

extension ChannelInfoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].count
    }

}
