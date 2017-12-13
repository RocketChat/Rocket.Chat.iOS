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
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint! {
        didSet {
            // Remove the bottom constraint if we don't support multi server
            if !AppManager.supportsMultiServer {
                tableViewBottomConstraint.constant = 0
            }
        }
    }

    @IBOutlet weak var activityViewSearching: UIActivityIndicatorView!

    weak var titleView: SubscriptionsTitleView?
    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

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

    weak var viewUserMenu: UIView? //SubscriptionUserStatusView?
    @IBOutlet weak var viewUser: SubscriptionUserView! {
        didSet {
            // let gesture = UITapGestureRecognizer(target: self, action: #selector(viewUserDidTap))
            // viewUser.addGestureRecognizer(gesture)
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

    var assigned = false
    var isSearchingLocally = false
    var isSearchingRemotely = false
    var searchResult: [Subscription]?
    var subscriptions: [Subscription]?
    var subscriptionsToken: NotificationToken?
    var currentUserToken: NotificationToken?

    var searchText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupServerButton()
        setupTitleView()
        updateBackButton()
        subscribeModelChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentUserInformation()

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardHandlers(tableView)
    }

    // MARK: Storyboard Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationCapturesStatusBarAppearance = true
    }

    // MARK: Setup Views

    func updateBackButton() {
        var unread = 0

        Realm.execute({ (realm) in
            for obj in realm.objects(Subscription.self) {
                unread += obj.unread
            }
        }, completion: {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(
                title: unread == 0 ? "" : "\(unread)",
                style: .plain,
                target: nil,
                action: nil
            )
        })
    }

    func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true

        if #available(iOS 11.0, *) {
            self.searchBar = searchController.searchBar
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true

            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
            tableView.tableHeaderView = searchBar
            self.searchBar = searchBar
        }

        self.searchController = searchController
        self.searchBar?.placeholder = localized("subscriptions.search")
        self.searchBar?.delegate = self
    }

    func setupTitleView() {
        if let titleView = SubscriptionsTitleView.instantiateFromNib() {
            titleView.user = AuthManager.currentUser()

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openUserContextMenu))
            titleView.addGestureRecognizer(tapGesture)

            navigationItem.titleView = titleView
            self.titleView = titleView
        }
    }

    func setupServerButton() {
        if let server = DatabaseManager.servers?[DatabaseManager.selectedIndex] {
            if let imageURL = URL(string: server[ServerPersistKeys.serverIconURL] ?? "") {
                let imageViewServer = UIImageView()
                imageViewServer.sd_setImage(with: imageURL)

                if #available(iOS 11.0, *) {
                    let buttonView = UIView()
                    imageViewServer.translatesAutoresizingMaskIntoConstraints = false
                    buttonView.addSubview(imageViewServer)

                    let views = ["imageView": imageViewServer]
                    buttonView.addConstraints(NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|-[imageView(25)]-|",
                        options: .alignAllCenterX,
                        metrics: nil,
                        views: views)
                    )

                    buttonView.addConstraints(NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-[imageView(25)]-|",
                        options: .alignAllCenterY,
                        metrics: nil,
                        views: views)
                    )

                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openServersList))
                    buttonView.addGestureRecognizer(tapGesture)

                    let buttonServer = UIBarButtonItem(customView: buttonView)
                    navigationItem.leftBarButtonItem = buttonServer
                } else {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openServersList))
                    imageViewServer.addGestureRecognizer(tapGesture)

                    imageViewServer.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
                    let buttonServer = UIBarButtonItem(customView: imageViewServer)
                    navigationItem.leftBarButtonItem = buttonServer
                }
            }
        }
    }
}

extension SubscriptionsViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "\n" {
            if searchText.count > 0 {
                searchOnSpotlight(searchText)
            }

            return
        }

        searchBy(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchText = ""
        searchBy()
    }

    func searchBy(_ text: String = "") {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.filterBy(name: text).sortedByLastMessageDate()
        searchText = text

        if text.count == 0 {
            isSearchingLocally = false
            isSearchingRemotely = false
            searchResult = []

            updateAll()
            tableView.reloadData()
            tableView.tableFooterView = nil

            return
        }

        if subscriptions?.count == 0 {
            searchOnSpotlight(text)
            return
        }

        isSearchingLocally = true
        isSearchingRemotely = false

        tableView.reloadData()

        if let footerView = SubscriptionSearchMoreView.instantiateFromNib() {
            footerView.delegate = self
            tableView.tableFooterView = footerView
        }
    }

    func searchOnSpotlight(_ text: String = "") {
        tableView.tableFooterView = nil

        SubscriptionManager.spotlight(text) { [weak self] result in
            let currentText = self?.searchController?.searchBar.text ?? ""

            if currentText.count == 0 {
                return
            }

            self?.isSearchingRemotely = true
            self?.searchResult = result
            self?.tableView.reloadData()
        }
    }

    func updateAll() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sortedByLastMessageDate()
    }

    func updateSearched() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.filterBy(name: searchText).sortedByLastMessageDate()
    }

    func updateData() {
        guard !isSearchingLocally && !isSearchingRemotely else { return }

        updateAll()
        updateCurrentUserInformation()

        tableView?.reloadData()
    }

    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>?) {
        if isSearchingLocally || isSearchingRemotely {
            updateSearched()
        } else {
            updateAll()
        }

        updateBackButton()
        updateCurrentUserInformation()
        SubscriptionManager.updateUnreadApplicationBadge()
        tableView?.reloadData()
    }

    func handleCurrentUserUpdates<T>(changes: RealmCollectionChange<RealmSwift.Results<T>>?) {
        titleView?.user = AuthManager.currentUser()
    }

    func handleSubscriptionUpdates<T>(changes: RealmCollectionChange<RealmSwift.Results<T>>?) {
        // Update titleView information with subscription, can be
        // some status changes
        if let subscription = ChatViewController.shared?.subscription {
            ChatViewController.shared?.chatTitleView?.subscription = subscription
        } else {
            ChatViewController.shared?.subscription = .initialSubscription()
        }

        // If side panel is visible, reload the data
        if isSearchingLocally || isSearchingRemotely {
            updateSearched()
        } else {
            updateAll()
        }

        tableView?.reloadData()
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
        guard let realm = Realm.shared else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }

        assigned = true

//        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
//        subscriptionsToken = subscriptions?.observe(handleSubscriptionUpdates)

        if let currentUserIdentifier = AuthManager.currentUser()?.identifier {
            let query = realm.objects(User.self).filter("identifier = %@", currentUserIdentifier)
            currentUserToken = query.observe(handleCurrentUserUpdates)
        }
    }

    func subscription(for indexPath: IndexPath) -> Subscription? {
        guard let subscriptions = subscriptions else { return nil }

        if subscriptions.count > indexPath.row {
            return Array(subscriptions)[indexPath.row]
        }

        return nil
    }

    func imageViewServerDidTapped(gesture: UIGestureRecognizer) {
        SubscriptionsPageViewController.shared?.showServersList()
    }

    // MARK: IBAction

    @objc func openServersList() {
        performSegue(withIdentifier: "Servers", sender: nil)
    }

    @objc func openUserContextMenu() {
        performSegue(withIdentifier: "User", sender: nil)
    }

}

extension SubscriptionsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions?.count ?? 0
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let subscription = subscription(for: indexPath) else { return }

        searchController?.searchBar.resignFirstResponder()

        if let controller = UIStoryboard(name: "Chat", bundle: Bundle.main).instantiateInitialViewController() as? ChatViewController {
            controller.subscription = subscription
            navigationController?.pushViewController(controller, animated: true)
        }
    }

}

extension SubscriptionsViewController {

    func showCancelSearchButton() {
        searchController?.searchBar.setShowsCancelButton(true, animated: true)
    }

    func hideCancelSearchButton() {
        searchController?.searchBar.setShowsCancelButton(false, animated: true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        searchText = (currentText as NSString).replacingCharacters(in: range, with: string)

        if string == "\n" {
            if currentText.count > 0 {
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
        searchOnSpotlight(searchController?.searchBar.text ?? "")
    }

    @IBAction func buttonAddChannelDidTap(sender: Any) {
        performSegue(withIdentifier: "New Channel", sender: sender)
    }

}
