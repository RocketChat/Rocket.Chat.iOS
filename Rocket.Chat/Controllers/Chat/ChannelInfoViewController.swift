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

    func cellForSubscriptionName() -> ChannelInfoBasicCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoBasicCell.identifier) as? ChannelInfoBasicCell else {
            return ChannelInfoBasicCell()
        }

        cell.labelTitle.text = "#\(subscription.name)"
        return cell
    }

    func cellForSubscriptionTopic() -> ChannelInfoDescriptionCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoDescriptionCell.identifier) as? ChannelInfoDescriptionCell else {
            return ChannelInfoDescriptionCell()
        }

        cell.labelTitle.text = localizedString("chat.info.item.topic")
        cell.labelDescription.text = "ChannelInfoDescriptionCell"
        return cell
    }

    func cellForUser() -> ChannelInfoUserCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoUserCell.identifier) as? ChannelInfoUserCell else {
            return ChannelInfoUserCell()
        }

        cell.labelTitle.text = subscription.name
        cell.labelSubtitle.text = subscription.otherUserId

        return cell
    }

}

// MARK: UITableViewDelegate

extension ChannelInfoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = tableViewData[indexPath.section][indexPath.row]

        if cellType == ChannelInfoUserCell.self {
            return cellForUser()
        }

        if cellType == ChannelInfoBasicCell.self {
            return cellForSubscriptionName()
        }

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
