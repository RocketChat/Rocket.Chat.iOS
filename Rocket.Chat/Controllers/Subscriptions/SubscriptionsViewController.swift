//
//  SubscriptionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift

final class SubscriptionsViewController: BaseViewController {
    enum SearchState {
        case searchingLocally
        case searchingRemotely
        case notSearching
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerViewSeparatorHeightConstraint: NSLayoutConstraint! {
        didSet {
            headerViewSeparatorHeightConstraint.constant = 0.5
        }
    }

    weak var titleView: SubscriptionsTitleView?
    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

    var assigned = false
    var searchState: SearchState = .notSearching
    var searchResult: [Subscription]?
    var subscriptions: [Subscription]?
    var subscriptionsToken: NotificationToken?
    var currentUserToken: NotificationToken?

    var subscriptionsToShow: [Subscription] {
        switch searchState {
        case .searchingLocally:
            return searchResult ?? []
        case .searchingRemotely:
            return searchResult ?? []
        case .notSearching:
            if let subscriptions = subscriptions {
                return Array(subscriptions)
            } else {
                return []
            }
        }
    }

    var searchText: String = ""

    let socketHandlerToken = String.random(5)

    deinit {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTitleView()
        updateBackButton()

        subscribeModelChanges()

        updateData()

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateData()

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    // MARK: Storyboard Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Servers" {
            segue.destination.modalPresentationCapturesStatusBarAppearance = true
        }
    }

    // MARK: Subscriptions

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }

        assigned = true

        let managedSubscriptions = auth.subscriptions.sortedByLastMessageDate()
        subscriptionsToken = managedSubscriptions.observe(handleSubscriptionUpdates)
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
            navigationItem.titleView = titleView
            self.titleView = titleView

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openServersList))
            titleView.addGestureRecognizer(tapGesture)

            titleView.delegate = self
            titleView.updateServerName(name: AuthSettingsManager.settings?.serverName)
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
            searchState = .notSearching
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

        searchState = .searchingLocally
        searchResult = subscriptions

        tableView.reloadData()

        if let footerView = SubscriptionSearchMoreView.instantiateFromNib() {
            footerView.delegate = self
            tableView.tableFooterView = footerView
        }
    }

    func searchOnSpotlight(_ text: String = "") {
        tableView.tableFooterView = nil

        API.current()?.client(SpotlightClient.self).search(query: text) { [weak self] result in
            let currentText = self?.searchBar?.text ?? ""

            if currentText.count == 0 {
                return
            }

            self?.searchState = .searchingRemotely
            self?.searchResult = result
            self?.tableView.reloadData()
        }
    }

    func updateSubscriptionsToShow() {
        switch searchState {
        case .notSearching:
            updateAll()
        case .searchingLocally, .searchingRemotely:
            updateSearched()
        }
    }

    func updateAll() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = Array(auth.subscriptions.sortedByLastMessageDate())
    }

    func updateSearched() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = Array(auth.subscriptions.sortedByLastMessageDate().filterBy(name: searchText))
    }

    func updateSubscriptionsList() {
        let visibleRows = self.tableView.indexPathsForVisibleRows ?? []

        self.updateBackButton()

        updateSubscriptionsToShow()

        // If the list were empty, let's just refresh everything.
        if visibleRows.count == 0 {
            self.tableView.reloadData()
            return
        }

        var selectedSubscriptionIdentifier: Subscription?
        if let nav = splitViewController?.detailViewController as? BaseNavigationController {
            if let controller = nav.viewControllers.first as? ChatViewController {
                selectedSubscriptionIdentifier = controller.subscription
            }
        }

        for indexPath in visibleRows {
            if let subscriptionCell = self.tableView.cellForRow(at: indexPath) as? SubscriptionCell {
                subscriptionCell.subscription = self.subscriptions?[indexPath.row]

                if subscriptionCell.subscription == selectedSubscriptionIdentifier {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                } else if indexPath == tableView.indexPathForSelectedRow {
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
        }
    }

    func updateData() {
        guard case .notSearching = searchState else { return }

        updateAll()
        updateServerInformation()
        updateSubscriptionsList()
    }

    func handleSubscriptionUpdates<T>(changes: RealmCollectionChange<Results<T>>?) {
        updateSubscriptionsList()
    }

    func updateServerInformation() {
        titleView?.updateServerName(name: AuthSettingsManager.settings?.serverName)
    }

    func subscription(for indexPath: IndexPath) -> Subscription? {
        if subscriptionsToShow.count > indexPath.row {
            return subscriptionsToShow[indexPath.row]
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

}

extension SubscriptionsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptionsToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as? SubscriptionCell else {
            return UITableViewCell()
        }

        if UIDevice.current.userInterfaceIdiom == .pad {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
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

        // When using iPads, we override the detail controller creating
        // a new instance.
        if splitViewController?.detailViewController as? BaseNavigationController != nil {
            if let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? ChatViewController {
                controller.subscription = subscription

                let nav = BaseNavigationController(rootViewController: controller)
                splitViewController?.showDetailViewController(nav, sender: self)
            }
        } else if let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? ChatViewController {
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

extension SubscriptionsViewController: SubscriptionsTitleViewDelegate {

    func userDidPressServerName() {
        openServersList()
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

extension SubscriptionsViewController: SocketConnectionHandler {

    func socketDidConnect(socket: SocketManager) {

    }

    func socketDidDisconnect(socket: SocketManager) {
        SocketManager.reconnect()
    }

    func socketDidReturnError(socket: SocketManager, error: SocketError) {
        // Handle errors
    }

}
