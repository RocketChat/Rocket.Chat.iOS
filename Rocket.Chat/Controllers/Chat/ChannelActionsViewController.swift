//
//  ChannelActionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

private typealias ListSegueData = (title: String, query: String?, isListingMentions: Bool)

class ChannelActionsViewController: BaseViewController {

    internal let kShareRoomSection = 2

    @IBOutlet weak var tableView: UITableView!

    weak var buttonFavorite: UIBarButtonItem?
    weak var shareRoomCell: UITableViewCell!

    var tableViewData: [[Any?]] = [] {
        didSet {
            tableView?.reloadData()
        }
    }

    var subscription: Subscription? {
        didSet {
            guard let subscription = self.subscription else { return }

            let isDirectMessage = subscription.type == .directMessage

            var header: [Any?]? = nil

            if subscription.type == .directMessage {
                header = [ChannelInfoUserCellData(user: subscription.directMessageUser)]
            } else {
                let hasDescription = !(subscription.roomDescription?.isEmpty ?? true)
                let hasTopic = !(subscription.roomTopic?.isEmpty ?? true)

                header = [
                    ChannelInfoBasicCellData(title: "#\(subscription.name)"),
                    ChannelInfoDescriptionCellData(
                        title: localized("chat.info.item.description"),
                        descriptionText: hasDescription ? subscription.roomDescription : localized("chat.info.item.no_description")
                    ),
                    ChannelInfoDescriptionCellData(
                        title: localized("chat.info.item.topic"),
                        descriptionText: hasTopic ? subscription.roomTopic : localized("chat.info.item.no_topic")
                    )
                ]
            }

            func title(for menuTitle: String) -> String {
                return localized("chat.info.item.\(menuTitle)")
            }

            let data = [header, [
                ChannelInfoActionCellData(icon: UIImage(named: "Attachments"), title: title(for: "files"), action: showFilesList),
                isDirectMessage ? nil : ChannelInfoActionCellData(icon: UIImage(named: "Mentions"), title: title(for: "mentions"), action: showMentionsList),
                isDirectMessage ? nil : ChannelInfoActionCellData(icon: UIImage(named: "Members"), title: title(for: "members"), action: showMembersList),
                ChannelInfoActionCellData(icon: UIImage(named: "Star"), title: title(for: "starred"), action: showStarredList),
                ChannelInfoActionCellData(icon: UIImage(named: "Pinned"), title: title(for: "pinned"), action: showPinnedList),
                ChannelInfoActionCellData(icon: UIImage(named: "Notifications"), title: title(for: "notifications"), action: showNotificationsSettings)
            ], [
                ChannelInfoActionCellData(icon: UIImage(named: "Share"), title: title(for: "share"), detail: false, action: shareRoom)
            ]]

            tableViewData = data.compactMap({ $0 })
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

        tableView?.register(UINib(
            nibName: "ChannelInfoDescriptionCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChannelInfoDescriptionCell.identifier)

        tableView?.register(UINib(
            nibName: "ChannelInfoBasicCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChannelInfoBasicCell.identifier)
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

    @IBAction func buttonCloseDidPressed(sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc func buttonFavoriteDidPressed(_ sender: Any) {
        guard let subscription = self.subscription else { return }

        SubscriptionManager.toggleFavorite(subscription) { [unowned self] (response) in
            DispatchQueue.main.async {
                if response.isError() {
                    subscription.updateFavorite(!subscription.favorite)
                }

                self.updateButtonFavoriteImage()
            }
        }

        self.subscription?.updateFavorite(!subscription.favorite)
        updateButtonFavoriteImage()
    }

}

// MARK: Actions

extension ChannelActionsViewController {

    func showUserDetails(_ user: User) {
        let controller = UserDetailViewController.fromStoryboard().withModel(.forUser(user))
        navigationController?.pushViewController(controller, animated: true)
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

    private func showNotificationsSettings() {
        self.performSegue(withIdentifier: "toNotificationsSettings", sender: self)
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

    func showFilesList() {
        let data = ListSegueData(
            title: localized("chat.messages.files.list.title"),
            query: nil,
            isListingMentions: false
        )

        self.performSegue(withIdentifier: "toFilesList", sender: data)
    }

    func shareRoom() {
        guard let url = subscription?.externalURL() else { return }
        let controller = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        if shareRoomCell != nil && UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = shareRoomCell
            controller.popoverPresentationController?.sourceRect = shareRoomCell.bounds
        }

        present(controller, animated: true, completion: nil)
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
                messagesList.data.isListingMentions = segueData.isListingMentions
            }
        }

        if let filesList = segue.destination as? FilesListViewController {
            filesList.data.subscription = self.subscription

            if let segueData = sender as? ListSegueData {
                filesList.data.title = segueData.title
            }
        }

        if let notificationsSettings = segue.destination as? NotificationsPreferencesViewController {
            notificationsSettings.subscription = subscription
        }
    }

}

// MARK: UITableViewDelegate

extension ChannelActionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoActionCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoActionCell.identifier) as? ChannelInfoActionCell {
                cell.data = data
                cell.separatorInset = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 0)
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

        if let data = data as? ChannelInfoBasicCellData {
            if let cell = tableView.dequeueReusableCell(withIdentifier: ChannelInfoBasicCell.identifier) as? ChannelInfoBasicCell {
                cell.data = data
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = tableViewData[indexPath.section][indexPath.row]

        if data as? ChannelInfoActionCellData != nil {
            return ChannelInfoActionCell.defaultHeight
        }

        if data as? ChannelInfoUserCellData != nil {
            return ChannelInfoUserCell.defaultHeight
        }

        if data as? ChannelInfoDescriptionCellData != nil {
            return ChannelInfoDescriptionCell.defaultHeight
        }

        if data as? ChannelInfoBasicCellData != nil {
            return ChannelInfoBasicCell.defaultHeight
        }

        return 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == kShareRoomSection && UIDevice.current.userInterfaceIdiom == .pad {
            shareRoomCell = tableView.cellForRow(at: indexPath)
        }

        let data = tableViewData[indexPath.section][indexPath.row]

        if let data = data as? ChannelInfoUserCellData, let user = data.user {
            showUserDetails(user)
        }

        if let data = data as? ChannelInfoActionCellData {
            guard let action = data.action else {
                alert(title: localized("alert.feature.wip.title"), message: localized("alert.feature.wip.message"))
                return
            }

            action()
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
