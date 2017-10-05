//
//  ChannelInfoViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

fileprivate typealias ListSegueData = (title: String, query: String?)

class ChannelInfoViewController: BaseViewController {

    var tableViewData: [[Any]] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var subscription: Subscription? {
        didSet {
            guard let subscription = self.subscription else { return }

            let channelInfoData = [
                ChannelInfoDetailCellData(title: localized("chat.info.item.members"), detail: "", action: showMembersList),
                ChannelInfoDetailCellData(title: localized("chat.info.item.pinned"), detail: "", action: showPinnedList),
                ChannelInfoDetailCellData(title: localized("chat.info.item.starred"), detail: "", action: showStarredList)
            ]

            if subscription.type == .directMessage {
                tableViewData = [[
                    ChannelInfoUserCellData(user: subscription.directMessageUser)
                ], channelInfoData]
            } else {
                let topic = subscription.roomTopic?.characters.count ?? 0 == 0 ? localized("chat.info.item.no_topic") : subscription.roomTopic
                let description = subscription.roomDescription?.characters.count ?? 0 == 0 ? localized("chat.info.item.no_description") : subscription.roomDescription

                tableViewData = [[
                    ChannelInfoBasicCellData(title: "#\(subscription.displayName())"),
                    ChannelInfoDescriptionCellData(
                        title: localized("chat.info.item.topic"),
                        description: topic
                    ),
                    ChannelInfoDescriptionCellData(
                        title: localized("chat.info.item.description"),
                        description: description
                    )
                ], channelInfoData]
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    weak var buttonFavorite: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = localized("chat.info.title")

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

    func showMembersList() {
        self.performSegue(withIdentifier: "toMembersList", sender: self)
    }

    func showPinnedList() {
        let data = ListSegueData(title: localized("pinnedlist.title"), query: "{\"pinned\":true}")
        self.performSegue(withIdentifier: "toMessagesList", sender: data)
    }

    func showStarredList() {
        guard let userId = AuthManager.currentUser()?.identifier else {
            alert(title: "Oops!", message: "Internal error: User not found!")
            return
        }

        let data = ListSegueData(title: localized("starredlist.title"), query: "{\"starred._id\":{\"$in\":[\"\(userId)\"]}}")
        self.performSegue(withIdentifier: "toMessagesList", sender: data)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let membersList = segue.destination as? MembersListViewController {
            membersList.data.subscription = self.subscription
        }

        if let messagesList = segue.destination as? MessagesListViewController {

            messagesList.data.subscription = self.subscription

            if let segueData = sender as? ListSegueData {
                messagesList.data.title = segueData.title
                messagesList.data.query = segueData.query
            }
        }
    }

    // MARK: IBAction

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

    @IBAction func buttonCloseDidPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: UITableViewDelegate

extension ChannelInfoViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoBasicCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoBasicCell.identifier) as? ChannelInfoBasicCell {
                cell.data = data
                return cell
            }
        }

        if let data = data as? ChannelInfoDetailCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoDetailCell.identifier) as? ChannelInfoDetailCell {
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

        if let data = data as? ChannelInfoDescriptionCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoDescriptionCell.identifier) as? ChannelInfoDescriptionCell {
                cell.data = data
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = tableViewData[indexPath.section][indexPath.row]

        if data as? ChannelInfoBasicCellData != nil {
            return CGFloat(ChannelInfoBasicCell.defaultHeight)
        }

        if data as? ChannelInfoDetailCellData != nil {
            return CGFloat(ChannelInfoDetailCell.defaultHeight)
        }

        if data as? ChannelInfoUserCellData != nil {
            return CGFloat(ChannelInfoUserCell.defaultHeight)
        }

        if data as? ChannelInfoDescriptionCellData != nil {
            return CGFloat(ChannelInfoDescriptionCell.defaultHeight)
        }

        return CGFloat(0)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoDetailCellData {
            guard let action = data.action else {
                alert(title: "Oops!", message: "We're still working on this feature, stay tunned!")
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

extension ChannelInfoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].count
    }

}
