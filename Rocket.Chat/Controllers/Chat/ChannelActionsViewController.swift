//
//  ChannelActionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChannelActionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    var tableViewData: [[Any]] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var subscription: Subscription? {
        didSet {
            guard let subscription = self.subscription else { return }

            let data = [[
                ChannelInfoUserCellData(user: subscription.directMessageUser)
            ], [
                ChannelInfoActionCellData(icon: UIImage(named: "Message"), title: "Message", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Call"), title: "Voice call", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Video"), title: "Video call", detail: true)
            ], [
                ChannelInfoActionCellData(icon: UIImage(named: "Attachments"), title: "Files", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Mentions"), title: "Mentions", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Starred"), title: "Starred", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Search"), title: "Search", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Share"), title: "Share", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Pinned"), title: "Pinned", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Snipped"), title: "Snippets", detail: true),
                ChannelInfoActionCellData(icon: UIImage(named: "Downloads"), title: "Downloads", detail: true)
            ]]

            tableViewData = data
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Actions"

        tableView?.register(UINib(
            nibName: "ChannelInfoUserCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChannelInfoUserCell.identifier)

        tableView?.register(UINib(
            nibName: "ChannelInfoActionCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChannelInfoActionCell.identifier)
    }

}

// MARK: UITableViewDelegate

extension ChannelActionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoActionCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoActionCell.identifier) as? ChannelInfoActionCell {
                cell.data = data
                return cell
            }
        }

        if let data = data as? ChannelInfoUserCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoUserCell.identifier) as? ChannelInfoUserCell {
                cell.data = data
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = tableViewData[indexPath.section][indexPath.row]

        if data as? ChannelInfoActionCellData != nil {
            return CGFloat(ChannelInfoActionCell.defaultHeight)
        }

        if data as? ChannelInfoUserCellData != nil {
            return CGFloat(ChannelInfoUserCell.defaultHeight)
        }

        return CGFloat(0)
    }

}

// MARK: UITableViewDataSource

extension ChannelActionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].count
    }

}
