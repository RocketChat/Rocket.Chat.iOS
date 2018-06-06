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
    enum SearchState {
        case searchingLocally
        case searchingRemotely
        case notSearching
    }

    @IBOutlet weak var tableView: UITableView!

    weak var sortingView: SubscriptionsSortingView?
    weak var serversView: ServersListView?
    weak var titleView: SubscriptionsTitleView?
    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

    var assigned = false
    var searchState: SearchState = .notSearching
    var searchResult: [Subscription]?
    var subscriptions: [Subscription]?
    var subscriptionsToken: NotificationToken?
    var currentUserToken: NotificationToken?

    var groupInfomation: [[String: String]]?
    var groupSubscriptions: [[Subscription]]?

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchBar()
        setupTitleView()
        updateBackButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        subscribeModelChanges()
        updateData()
        tableView.reloadData()

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        subscriptionsToken?.invalidate()
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
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

    // swiftlint:disable function_body_length cyclomatic_complexity
    func organizeSubscriptionsGrouped() {
        var unreadGroup: [Subscription] = []
        var favoriteGroup: [Subscription] = []
        var channelGroup: [Subscription] = []
        var directMessageGroup: [Subscription] = []
        var searchResultsGroup: [Subscription] = []

        let isSearchingRemotely = searchState == .searchingRemotely
        let isSearchingLocally = searchState == .searchingLocally

        guard let subscriptions = subscriptions else { return }
        let orderSubscriptions = isSearchingRemotely ? searchResult : subscriptions

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
                "name": localized("subscriptions.search_results")
            ])

            searchResultsGroup = searchResultsGroup.sorted {
                return $0.displayName() < $1.displayName()
            }

            groupSubscriptions?.append(searchResultsGroup)
        } else {
            if unreadGroup.count > 0 {
                groupInfomation?.append([
                    "name": localized("subscriptions.unreads")
                ])

                unreadGroup = unreadGroup.sorted {
                    return ($0.type.rawValue, $0.name.lowercased()) < ($1.type.rawValue, $1.name.lowercased())
                }

                groupSubscriptions?.append(unreadGroup)
            }

            if favoriteGroup.count > 0 {
                groupInfomation?.append([
                    "name": localized("subscriptions.favorites")
                ])

                favoriteGroup = favoriteGroup.sorted {
                    return ($0.type.rawValue, $0.name.lowercased()) < ($1.type.rawValue, $1.name.lowercased())
                }

                groupSubscriptions?.append(favoriteGroup)
            }

            if channelGroup.count > 0 {
                groupInfomation?.append([
                    "name": localized("subscriptions.channels")
                ])

                groupSubscriptions?.append(channelGroup)
            }

            if directMessageGroup.count > 0 {
                groupInfomation?.append([
                    "name": localized("subscriptions.direct_messages")
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
            updateServerInformation()
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
        organizeSubscriptionsGrouped()
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
        if let serverName = AuthSettingsManager.settings?.serverName {
            titleView?.updateServerName(name: serverName)
        } else if let serverURL = AuthManager.isAuthenticated()?.serverURL {
            if let host = URL(string: serverURL)?.host {
                titleView?.updateServerName(name: host)
            } else {
                titleView?.updateServerName(name: serverURL)
            }
        } else {
            titleView?.updateServerName(name: "Rocket.Chat")
        }
    }

    // MARK: IBAction

    @IBAction func buttonSortingOptionsDidPressed(sender: Any) {
        if let sortingView = self.sortingView {
            sortingView.close()
        } else {
            sortingView = SubscriptionsSortingView.showIn(self.view)
        }
    }

    @objc func openServersList() {
        if let serversView = self.serversView {
            titleView?.updateTitleImage(reverse: false)
            serversView.close()
        } else {
            titleView?.updateTitleImage(reverse: true)
            serversView = ServersListView.showIn(self.view)
            serversView?.delegate = self
        }
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
        return groupInfomation?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSubscriptions?[section].count ?? 0
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

        view.setTitle(group["name"])
        return view
    }

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

extension SubscriptionsViewController: ServerListViewDelegate {
    func serverListViewDidClose() {
        titleView?.updateTitleImage(reverse: false)
    }
}
