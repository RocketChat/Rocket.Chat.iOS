//
//  SubscriptionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift

// swiftlint:disable file_length
final class SubscriptionsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityViewSearching: UIActivityIndicatorView!

    let defaultButtonCancelSearchWidth = CGFloat(65)
    @IBOutlet weak var buttonCancelSearch: UIButton! {
        didSet {
            buttonCancelSearch.setTitle(localized("global.cancel"), for: .normal)
        }
    }
    @IBOutlet weak var buttonCancelSearchWidthConstraint: NSLayoutConstraint! {
        didSet {
            buttonCancelSearchWidthConstraint.constant = 0
        }
    }

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

    class func sharedInstance() -> SubscriptionsViewController? {
        if let main = UIApplication.shared.delegate?.window??.rootViewController as? MainChatViewController {
            if let nav = main.sideViewController as? UINavigationController {
                return nav.viewControllers.first as? SubscriptionsViewController
            }
        }

        return nil
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
        registerKeyboardHandlers(tableView)
    }
}

extension SubscriptionsViewController {

    @IBAction func buttonCancelSearchDidPressed(_ sender: Any) {
        textFieldSearch.resignFirstResponder()
    }

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

    func updateData() {
        guard !isSearchingLocally && !isSearchingRemotely else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        groupSubscription()
        updateCurrentUserInformation()
        tableView?.reloadData()
    }

    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>?) {
        guard !isSearchingLocally && !isSearchingRemotely else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        groupSubscription()

        updateCurrentUserInformation()
        SubscriptionManager.updateUnreadApplicationBadge()

        if MainChatViewController.shared()?.sidePanelVisible ?? false {
            tableView?.reloadData()
        }
    }

    func updateCurrentUserInformation() {
        guard let user = AuthManager.currentUser() else { return }
        guard let labelUsername = self.labelUsername else { return }
        guard let viewUserStatus = self.viewUserStatus else { return }

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

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }

        assigned = true

        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        subscriptionsToken = subscriptions?.addNotificationBlock(handleModelUpdates)
        usersToken = try? Realm().objects(User.self).addNotificationBlock(handleModelUpdates)

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

    func subscription(for indexPath: IndexPath) -> Subscription? {
        guard let groups = groupSubscriptions else { return nil }
        guard groups.count > indexPath.section else { return nil }
        guard groups[indexPath.section].count > indexPath.row else { return nil }
        return groups[indexPath.section][indexPath.row]
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

        if let subscription = subscription(for: indexPath) {
            cell.subscription = subscription
        }

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

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let subscription = subscription(for: indexPath) else { return }

        let controller = ChatViewController.sharedInstance()
        controller?.closeSidebarAfterSubscriptionUpdate = true
        controller?.subscription = subscription
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SubscriptionCell else { return }
        guard let subscription = cell.subscription else { return }
        guard let selectedSubscription = ChatViewController.sharedInstance()?.subscription else { return }

        if subscription.identifier == selectedSubscription.identifier {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}

extension SubscriptionsViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        buttonCancelSearchWidthConstraint.constant = defaultButtonCancelSearchWidth

        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        buttonCancelSearchWidthConstraint.constant = 0

        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

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

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchBy()
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

        if viewUserMenu != nil {
            dismissUserMenu()
        } else {
            presentUserMenu()
        }
    }

    func userDidPressedOption() {
        dismissUserMenu()
    }
}
