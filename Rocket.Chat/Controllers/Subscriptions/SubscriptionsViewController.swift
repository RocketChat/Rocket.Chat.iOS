//
//  SubscriptionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift

final class SubscriptionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityViewSearching: UIActivityIndicatorView!
    @IBOutlet weak var textFieldSearch: UITextField! {
        didSet {
            textFieldSearch.placeholder = localized("subscriptions.search")

            if let placeholder = textFieldSearch.placeholder {
                let color = UIColor(rgb: 0x9AB1BF, alphaVal: 1)
                textFieldSearch.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: color])
            }
        }
    }

    @IBOutlet weak var viewTextField: UIView! {
        didSet {
            viewTextField.layer.cornerRadius = 4
            viewTextField.layer.masksToBounds = true
        }
    }

    weak var viewUserMenu: SubscriptionUserStatusView?
    @IBOutlet weak var viewUser: UIView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(viewUserDidTap))
            viewUser.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet weak var viewUserStatus: UIView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var imageViewArrowDown: UIImageView! {
        didSet {
            imageViewArrowDown.image = imageViewArrowDown.image?.imageWithTint(.RCLightBlue())
        }
    }

    var assigned = false
    var isSearchingLocally = false
    var isSearchingRemotely = false
    var searchResult: [Subscription]?
    var subscriptions: Results<Subscription>?
    var subscriptionsToken: NotificationToken?
    var usersToken: NotificationToken?

    var groupInfomation: [[String: String]]?
    var groupSubscriptions: [[Subscription]]?

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeModelChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentUserInformation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
        dismissUserMenu()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        registerKeyboardHandlers(tableView)
    }
}

extension SubscriptionsViewController {

    func searchBy(_ text: String = "") {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.filter("name CONTAINS %@", text)

        if text.characters.count == 0 {
            isSearchingLocally = false
            isSearchingRemotely = false
            searchResult = []

            groupSubscription()
            tableView.reloadData()
            tableView.tableFooterView = nil

            activityViewSearching.stopAnimating()

            return
        }

        if subscriptions?.count == 0 {
            searchOnSpotlight(text)
            return
        }

        isSearchingLocally = true
        isSearchingRemotely = false

        groupSubscription()
        tableView.reloadData()

        if let footerView = SubscriptionSearchMoreView.instantiateFromNib() {
            footerView.delegate = self
            tableView.tableFooterView = footerView
        }
    }

    func searchOnSpotlight(_ text: String = "") {
        tableView.tableFooterView = nil
        activityViewSearching.startAnimating()

        SubscriptionManager.spotlight(text) { [weak self] result in
            let currentText = self?.textFieldSearch.text ?? ""

            if currentText.characters.count == 0 {
                return
            }

            self?.activityViewSearching.stopAnimating()
            self?.isSearchingRemotely = true
            self?.searchResult = result
            self?.groupSubscription()
            self?.tableView.reloadData()
        }
    }

    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>?) {
        guard !isSearchingLocally && !isSearchingRemotely else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        groupSubscription()
        updateCurrentUserInformation()
        tableView?.reloadData()
    }

    func updateCurrentUserInformation() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let labelUsername = self.labelUsername else { return }
        guard let viewUserStatus = self.viewUserStatus else { return }

        Realm.execute { (realm) in
            if let user = realm.object(ofType: User.self, forPrimaryKey: auth.userId) {
                labelUsername.text = user.username ?? ""

                switch user.status {
                case .online:
                    viewUserStatus.backgroundColor = .RCOnline()
                    break
                case .busy:
                    viewUserStatus.backgroundColor = .RCBusy()
                    break
                case .away:
                    viewUserStatus.backgroundColor = .RCAway()
                    break
                case .offline:
                    viewUserStatus.backgroundColor = .RCInvisible()
                    break
                }
            }
        }
    }

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }

        assigned = true

        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        subscriptionsToken = subscriptions?.addNotificationBlock(handleModelUpdates)
        usersToken = try? Realm().addNotificationBlock { [weak self] _, _ in
            self?.handleModelUpdates(nil)
        }

        groupSubscription()
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func groupSubscription() {
        var unreadGroup: [Subscription] = []
        var favoriteGroup: [Subscription] = []
        var channelGroup: [Subscription] = []
        var directMessageGroup: [Subscription] = []
        var searchResultsGroup: [Subscription] = []

        guard let subscriptions = subscriptions else { return }
        let orderSubscriptions = isSearchingRemotely ? searchResult : Array(subscriptions.sorted(byKeyPath: "name", ascending: true))

        for subscription in orderSubscriptions ?? [] {
            if isSearchingRemotely {
                searchResultsGroup.append(subscription)
            }

            if !isSearchingLocally && !subscription.open {
                continue
            }

            if subscription.alert {
                unreadGroup.append(subscription)
                continue
            }

            if subscription.favorite {
                favoriteGroup.append(subscription)
                continue
            }

            switch subscription.type {
            case .channel, .group:
                channelGroup.append(subscription)
            case .directMessage:
                directMessageGroup.append(subscription)
            }
        }

        groupInfomation = [[String: String]]()
        groupSubscriptions = [[Subscription]]()

        if searchResultsGroup.count > 0 {
            groupInfomation?.append([
                "name": String(format: "%@ (%d)", localized("subscriptions.search_results"), searchResultsGroup.count)
            ])

            searchResultsGroup = searchResultsGroup.sorted {
                return $0.name < $1.name
            }

            groupSubscriptions?.append(searchResultsGroup)
        } else {
        
            if unreadGroup.count > 0 {
                groupInfomation?.append([
                    "name": String(format: "%@ (%d)", localized("subscriptions.unreads"), unreadGroup.count)
                ])

                unreadGroup = unreadGroup.sorted {
                    return $0.type.rawValue < $1.type.rawValue
                }

                groupSubscriptions?.append(unreadGroup)
                NotificationCenter.default.post(name: Notification.Name("Unread_Message_Notification"), object: nil)
            } else {
                NotificationCenter.default.post(name: Notification.Name("All_Messages_Read_Notification"), object: nil)
            }

            if favoriteGroup.count > 0 {
                groupInfomation?.append([
                    "icon": "Star",
                    "name": String(format: "%@ (%d)", localized("subscriptions.favorites"), favoriteGroup.count)
                    ])
                favoriteGroup = favoriteGroup.sorted {
                return $0.type.rawValue < $1.type.rawValue
                }

                groupSubscriptions?.append(favoriteGroup)
            }

            if channelGroup.count > 0 {
                groupInfomation?.append([
                    "name": String(format: "%@ (%d)", localized("subscriptions.channels"), channelGroup.count)
                    ])

                groupSubscriptions?.append(channelGroup)
            }

            if directMessageGroup.count > 0 {
                groupInfomation?.append([
                    "name": String(format: "%@ (%d)", localized("subscriptions.direct_messages"), directMessageGroup.count)
                ])

                groupSubscriptions?.append(directMessageGroup)
            }
        }
    }
}

extension SubscriptionsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupInfomation?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSubscriptions?[section].count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as? SubscriptionCell else {
            return UITableViewCell()
        }

        let subscription = groupSubscriptions?[indexPath.section][indexPath.row]
        cell.subscription = subscription

        return cell
    }
}

extension SubscriptionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 60
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let group = groupInfomation?[section] else { return nil }
        guard let view = SubscriptionSectionView.instantiateFromNib() else {
            return nil
        }

        view.setIconName(group["icon"])
        view.setTitle(group["name"])

        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subscription = self.groupSubscriptions?[indexPath.section][indexPath.row]
        let controller = ChatViewController.sharedInstance()
        controller?.closeSidebarAfterSubscriptionUpdate = true
        controller?.subscription = subscription
    }
}

extension SubscriptionsViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if string == "\n" {
            if currentText.characters.count > 0 {
                searchOnSpotlight(currentText)
            }

            return false
        }

        searchBy(prospectiveText)
        return true
    }
}

extension SubscriptionsViewController: SubscriptionSearchMoreViewDelegate {

    func buttonLoadMoreDidPressed() {
        searchOnSpotlight(textFieldSearch.text ?? "")
    }
}

extension SubscriptionsViewController: SubscriptionUserStatusViewProtocol {

    func presentUserMenu() {
        guard let viewUserMenu = SubscriptionUserStatusView.instantiateFromNib() else { return }

        var newFrame = view.frame
        newFrame.origin.y = -newFrame.height
        viewUserMenu.frame = newFrame
        viewUserMenu.delegate = self
        viewUserMenu.parentController = self

        view.addSubview(viewUserMenu)
        self.viewUserMenu = viewUserMenu

        newFrame.origin.y = 64
        UIView.animate(withDuration: 0.15) {
            viewUserMenu.frame = newFrame
            self.imageViewArrowDown.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }

    func dismissUserMenu() {
        guard let viewUserMenu = viewUserMenu else { return }

        var newFrame = viewUserMenu.frame
        newFrame.origin.y = -newFrame.height

        UIView.animate(withDuration: 0.15, animations: {
            viewUserMenu.frame = newFrame
            self.imageViewArrowDown.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        }) { (_) in
            viewUserMenu.removeFromSuperview()
        }
    }

    func viewUserDidTap(sender: Any) {
        textFieldSearch.resignFirstResponder()

        if let _ = viewUserMenu {
            dismissUserMenu()
        } else {
            presentUserMenu()
        }
    }

    func userDidPressedOption() {
        dismissUserMenu()
    }

}
