//
//  ChannelInfoViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

private typealias ListSegueData = (title: String, query: String?, isListingMentions: Bool)

class ChannelInfoViewController: BaseViewController, UITextViewDelegate {

    var tableViewData: [[Any]] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var subscription: Subscription? {
        didSet {
            guard let subscription = self.subscription else { return }

            let shouldListMentions = subscription.type != .directMessage
            let channelInfoData = [
                ChannelInfoDetailCellData(title: localized("chat.info.item.members"), detail: "", action: showMembersList),
                ChannelInfoDetailCellData(title: localized("chat.info.item.pinned"), detail: "", action: showPinnedList),
                ChannelInfoDetailCellData(title: localized("chat.info.item.starred"), detail: "", action: showStarredList),
                shouldListMentions ? ChannelInfoDetailCellData(title: localized("chat.info.item.mentions"), detail: "", action: showMentionsList) : nil
            ].compactMap({$0})

            if subscription.type == .directMessage {
                tableViewData = [[
                    ChannelInfoUserCellData(user: subscription.directMessageUser)
                ], channelInfoData]
            } else {
                let topic = subscription.roomTopic?.count ?? 0 == 0 ? localized("chat.info.item.no_topic") : subscription.roomTopic
                let description = subscription.roomDescription?.count ?? 0 == 0 ? localized("chat.info.item.no_description") : subscription.roomDescription

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
    weak var saveButton: UIBarButtonItem?

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

        if let currentUser = AuthManager.currentUser() {
            if currentUser == subscription?.roomOwner {
                let saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
                navigationItem.rightBarButtonItems?.append(saveButton)
                self.saveButton = saveButton
                self.saveButton?.isEnabled = false
            }
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
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
        let data = ListSegueData(
            title: localized("chat.messages.pinned.list.title"),
            query: "{\"pinned\":true}",
            isListingMentions: false
        )

        self.performSegue(withIdentifier: "toMessagesList", sender: data)
    }

    func showStarredList() {
        guard let userId = AuthManager.currentUser()?.identifier else {
            alert(title: localized("error.socket.default_error.title"), message: localized("error.socket.default_error.message"))
            return
        }

        let data = ListSegueData(
            title: localized("chat.messages.starred.list.title"),
            query: "{\"starred._id\":{\"$in\":[\"\(userId)\"]}}",
            isListingMentions: false
        )

        self.performSegue(withIdentifier: "toMessagesList", sender: data)
    }

    func showMentionsList() {
        let data = ListSegueData(
            title: localized("chat.messages.mentions.list.title"),
            query: nil,
            isListingMentions: true
        )

        self.performSegue(withIdentifier: "toMessagesList", sender: data)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let membersList = segue.destination as? MembersListViewController {
            membersList.delegate = self
            membersList.data.subscription = self.subscription
        }

        if let messagesList = segue.destination as? MessagesListViewController {

            messagesList.data.subscription = self.subscription

            if let segueData = sender as? ListSegueData {
                messagesList.data.title = segueData.title
                messagesList.data.query = segueData.query
                messagesList.data.isListingMentions = segueData.isListingMentions
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

    @objc func saveButtonTapped(_ sender: Any) {
        guard let subscription = self.subscription else { return }

        guard let descriptionCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ChannelInfoDescriptionCell else { return }
        guard let description = descriptionCell.labelDescription.text else { return }

        SubscriptionManager.updateRoomDescription(subscription: subscription, description: description) { response in
            Log.debug(response.msg.debugDescription)
        }

        self.saveButton?.isEnabled = false
        hideKeyboard()
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
                cell.labelDescription.delegate = self

                if saveButton != nil && indexPath == IndexPath(row: 2, section: 0) {
                    cell.labelDescription.isUserInteractionEnabled = true
                }

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

extension ChannelInfoViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData[section].count
    }

}

// MARK: MembersListDelegate

extension ChannelInfoViewController: MembersListDelegate {
    func membersList(_ controller: MembersListViewController, didSelectUser user: User) {
        guard let username = user.username else { return }

        AppManager.openDirectMessage(username: username) {
            controller.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: UITextViewDelegate

extension ChannelInfoViewController {

    func textViewDidChange(_ textView: UITextView) {
        let currentDescription = subscription?.roomDescription
        let newDescription = textView.text

        if currentDescription == newDescription {
            self.saveButton?.isEnabled = false
        } else {
            self.saveButton?.isEnabled = true
        }
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }

}
