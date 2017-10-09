//
//  ChannelActionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

fileprivate typealias ListSegueData = (title: String, query: String?)

class ChannelActionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var buttonFavorite: UIBarButtonItem?

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
                ChannelInfoActionCellData(icon: UIImage(named: "Message"), title: "Message", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Call"), title: "Voice call", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Video"), title: "Video call", action: nil)
            ], [
                ChannelInfoActionCellData(icon: UIImage(named: "Attachments"), title: "Files", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Mentions"), title: "Mentions", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Pinned"), title: "Members", action: showMembersList),
                ChannelInfoActionCellData(icon: UIImage(named: "Starred"), title: "Starred", action: showStarredList),
                ChannelInfoActionCellData(icon: UIImage(named: "Search"), title: "Search", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Share"), title: "Share", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Pinned"), title: "Pinned", action: showPinnedList),
                ChannelInfoActionCellData(icon: UIImage(named: "Snipped"), title: "Snippets", action: nil),
                ChannelInfoActionCellData(icon: UIImage(named: "Downloads"), title: "Downloads", action: nil)
            ]]

            tableViewData = data
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Actions"

        if #available(iOS 11.0, *) {
            tableView?.contentInsetAdjustmentBehavior = .never
        }

        setupFavoriteButton()
        registerCells()
    }

    func registerCells() {
        tableView?.register(UINib(
            nibName: "ChannelInfoUserCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChannelInfoUserCell.identifier)

        tableView?.register(UINib(
            nibName: "ChannelInfoActionCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChannelInfoActionCell.identifier)
    }

    func setupFavoriteButton() {
        if let settings = AuthSettingsManager.settings {
            if settings.favoriteRooms {
                let defaultImage = UIImage(named: "Star")?.imageWithTint(UIColor.RCGray()).withRenderingMode(.alwaysOriginal)
                let buttonFavorite = UIBarButtonItem(image: defaultImage, style: .plain, target: self, action: #selector(buttonFavoriteDidPressed))
                navigationItem.rightBarButtonItem = buttonFavorite
                self.buttonFavorite = buttonFavorite
                updateButtonFavoriteImage()
            }
        }
    }

    func updateButtonFavoriteImage(_ force: Bool = false, value: Bool = false) {
        guard let buttonFavorite = self.buttonFavorite else { return }
        let favorite = force ? value : subscription?.favorite ?? false
        var image: UIImage?

        if favorite {
            image = UIImage(named: "Star-Filled")?.imageWithTint(UIColor.RCFavoriteMark())
        } else {
            image = UIImage(named: "Star")?.imageWithTint(UIColor.RCGray())
        }

        buttonFavorite.image = image?.withRenderingMode(.alwaysOriginal)
    }

}

// MARK: IBAction

extension ChannelActionsViewController {

    @objc func buttonFavoriteDidPressed(_ sender: Any) {
        guard let subscription = self.subscription else { return }

        SubscriptionManager.toggleFavorite(subscription) { [unowned self] (response) in
            if response.isError() {
                subscription.updateFavorite(!subscription.favorite)
            }

            self.updateButtonFavoriteImage()
        }

        self.subscription?.updateFavorite(!subscription.favorite)
        updateButtonFavoriteImage()
    }

}

// MARK: Actions

extension ChannelActionsViewController {

    func showMembersList() {
        guard let controller = UIStoryboard.controller(from: "Chat", identifier: "MembersList") as? MembersListViewController else {
            return assertionFailure("controller could not be initialized")
        }

        controller.data.subscription = self.subscription
        navigationController?.pushViewController(controller, animated: true)
    }

    func showPinnedList() {
        guard let controller = UIStoryboard.controller(from: "Chat", identifier: "MessagesList") as? MessagesListViewController else {
            return assertionFailure("controller could not be initialized")
        }

        controller.data.subscription = self.subscription
        controller.data.title = localized("chat.messages.pinned.list.title")
        controller.data.query = "{\"pinned\":true}"
        navigationController?.pushViewController(controller, animated: true)
    }

    func showStarredList() {
        guard let userId = AuthManager.currentUser()?.identifier else {
            alert(title: localized("error.socket.default_error_title"), message: "error.socket.default_error_message")
            return
        }

        guard let controller = UIStoryboard.controller(from: "Chat", identifier: "MessagesList") as? MessagesListViewController else {
            return assertionFailure("controller could not be initialized")
        }

        controller.data.subscription = self.subscription
        controller.data.title = localized("chat.messages.starred.list.title")
        controller.data.query = "{\"starred._id\":{\"$in\":[\"\(userId)\"]}}"
        navigationController?.pushViewController(controller, animated: true)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoActionCellData {
            guard let action = data.action else {
                alert(title: localized("alert.feature.wip.title"), message: localized("alert.feature.wip.message"))
                return
            }

            action()

            if let selectedIndex = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndex, animated: true)
            }
        }
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
