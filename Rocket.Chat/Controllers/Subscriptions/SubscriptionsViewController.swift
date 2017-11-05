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
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            // Remove the bottom constraint if we don't support multi server
            if !AppManager.supportsMultiServer {
                tableViewBottomConstraint.constant = 0
            }
        }
    }

    @IBOutlet weak var activityViewSearching: UIActivityIndicatorView!

    let defaultButtonCancelSearchWidth = CGFloat(65)
    @IBOutlet weak var buttonCancelSearch: UIButton! {
        didSet {
            buttonCancelSearch.setTitle(localized("global.cancel"), for: .normal)
        }
    }
    @IBOutlet weak var buttonCancelSearchWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var textFieldSearch: UITextField! {
        didSet {
            textFieldSearch.placeholder = localized("subscriptions.search")

            if let placeholder = textFieldSearch.placeholder {
                let color = UIColor(rgb: 0x9ea2a4, alphaVal: 1)
                textFieldSearch.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: color])
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

    weak var avatarView: AvatarView?
    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.masksToBounds = true
            avatarViewContainer.layer.cornerRadius = 5

            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: avatarViewContainer.frame.width,
                    height: avatarViewContainer.frame.height
                )

                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    @IBOutlet weak var labelServer: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonAddChannel: UIButton! {
        didSet {
            if let image = UIImage(named: "Add") {
                buttonAddChannel.tintColor = .RCLightBlue()
                buttonAddChannel.setImage(image, for: .normal)
            }
        }
    }
    @IBOutlet weak var imageViewArrowDown: UIImageView! {
        didSet {
            imageViewArrowDown.image = imageViewArrowDown.image?.imageWithTint(.RCLightBlue())
        }
    }

    static var shared: SubscriptionsViewController? {
        if let pageController = SubscriptionsPageViewController.shared {
            return pageController.subscriptionsController
        }

        return nil
    }

    var assigned = false
    var isSearchingLocally = false
    var isSearchingRemotely = false
    var searchResult: [Subscription]?
    var subscriptions: Results<Subscription>?
    var subscriptionsToken: NotificationToken?
    var currentUserToken: NotificationToken?

    var groupInfomation: [[String: String]]?
    var groupSubscriptions: [[Subscription]]?

    var searchText: String = ""

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

// MARK: Side Menu callbacks
extension SubscriptionsViewController {
    func willHide() {
        self.textFieldSearch.resignFirstResponder()
    }

    func didHide() {
        self.textFieldSearch.resignFirstResponder()
    }

    func willReveal() {
        if searchText.isEmpty {
            hideCancelSearchButton()
        } else {
            showCancelSearchButton()
        }

        self.textFieldSearch.resignFirstResponder()
        self.updateData()
    }

    func didReveal() {
        self.textFieldSearch.resignFirstResponder()
    }
}

extension SubscriptionsViewController {

    @IBAction func buttonCancelSearchDidPressed(_ sender: Any) {
        textFieldSearch.resignFirstResponder()
        textFieldSearch.text = ""
        searchText = ""
        searchBy()
    }

    func searchBy(_ text: String = "") {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.filterBy(name: text)

        if text.characters.count == 0 {
            isSearchingLocally = false
            isSearchingRemotely = false
            searchResult = []

            updateAll()
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

    func updateAll() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sortedByLastSeen()
    }

    func updateSearched() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.filterBy(name: searchText).sortedByLastSeen()
    }

    func updateData() {
        guard !isSearchingLocally && !isSearchingRemotely else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        groupSubscription()
        updateCurrentUserInformation()
        tableView?.reloadData()
    }

    func handleCurrentUserUpdates<T>(changes: RealmCollectionChange<RealmSwift.Results<T>>?) {
        updateCurrentUserInformation()
    }

    func handleSubscriptionUpdates<T>(changes: RealmCollectionChange<RealmSwift.Results<T>>?) {
        // Update titleView information with subscription, can be
        // some status changes
        if let subscription = ChatViewController.shared?.subscription {
            ChatViewController.shared?.chatTitleView?.subscription = subscription
        }

        // If side panel is visible, reload the data
        if MainChatViewController.shared?.sidePanelVisible ?? false {
            if isSearchingLocally || isSearchingRemotely {
                updateSearched()
            } else {
                updateAll()
            }

            groupSubscription()
            tableView?.reloadData()
        }
    }

    func updateCurrentUserInformation() {
        guard let settings = AuthSettingsManager.settings else { return }
        guard let user = AuthManager.currentUser() else { return }
        guard let labelUsername = self.labelUsername else { return }
        guard let viewUserStatus = self.viewUserStatus else { return }
        guard let avatarView = self.avatarView else { return }

        labelServer.text = settings.serverName
        labelUsername.text = user.displayName()
        avatarView.user = user

        switch user.status {
        case .online:
            viewUserStatus.backgroundColor = .RCOnline()
        case .busy:
            viewUserStatus.backgroundColor = .RCBusy()
        case .away:
            viewUserStatus.backgroundColor = .RCAway()
        case .offline:
            viewUserStatus.backgroundColor = .RCInvisible()
        }
    }

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let realm = Realm.shared else { return }

        assigned = true

        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        subscriptionsToken = subscriptions?.observe(handleSubscriptionUpdates)

        if let currentUserIdentifier = AuthManager.currentUser()?.identifier {
            let query = realm.objects(User.self).filter("identifier = %@", currentUserIdentifier)
            currentUserToken = query.observe(handleCurrentUserUpdates)
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
                return $0.displayName() < $1.displayName()
            }

            groupSubscriptions?.append(searchResultsGroup)
        } else {
            if unreadGroup.count > 0 {
                groupInfomation?.append([
                    "name": String(format: "%@ (%d)", localized("subscriptions.unreads"), unreadGroup.count)
                ])

                unreadGroup = unreadGroup.sorted {
                    return ($0.type.rawValue, $0.name.lowercased()) < ($1.type.rawValue, $1.name.lowercased())
                }

                groupSubscriptions?.append(unreadGroup)
            }

            if favoriteGroup.count > 0 {
                groupInfomation?.append([
                    "icon": "Star",
                    "name": String(format: "%@ (%d)", localized("subscriptions.favorites"), favoriteGroup.count)
                ])

                favoriteGroup = favoriteGroup.sorted {
                    return ($0.type.rawValue, $0.name.lowercased()) < ($1.type.rawValue, $1.name.lowercased())
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

    func imageViewServerDidTapped(gesture: UIGestureRecognizer) {
        SubscriptionsPageViewController.shared?.showServersList()
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
        return 60
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard
            groupInfomation?.count ?? 0 > section,
            let group = groupInfomation?[section],
            let view = SubscriptionSectionView.instantiateFromNib()
        else {
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

        let controller = ChatViewController.shared
        controller?.closeSidebarAfterSubscriptionUpdate = true
        controller?.subscription = subscription
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SubscriptionCell else { return }
        guard let subscription = cell.subscription else { return }
        guard let selectedSubscription = ChatViewController.shared?.subscription else { return }

        if subscription.identifier == selectedSubscription.identifier {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}

extension SubscriptionsViewController: UITextFieldDelegate {

    func showCancelSearchButton() {
        buttonCancelSearchWidthConstraint.constant = defaultButtonCancelSearchWidth
    }

    func hideCancelSearchButton() {
        buttonCancelSearchWidthConstraint.constant = 0
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.showCancelSearchButton()

        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        hideCancelSearchButton()

        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        searchText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if string == "\n" {
            if currentText.characters.count > 0 {
                searchOnSpotlight(currentText)
            }

            return false
        }

        searchBy(searchText)
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

        newFrame.origin.y = 84
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
        }, completion: { (_) in
            viewUserMenu.removeFromSuperview()
        })
    }

    @objc func viewUserDidTap(sender: Any) {
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

    @IBAction func buttonAddChannelDidTap(sender: Any) {
        performSegue(withIdentifier: "New Channel", sender: sender)
    }

}
