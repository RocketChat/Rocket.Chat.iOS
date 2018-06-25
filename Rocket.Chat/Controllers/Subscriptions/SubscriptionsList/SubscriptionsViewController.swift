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
    @IBOutlet weak var filterSeperator: UIView!
    @IBOutlet weak var labelSortingTitleDescription: UILabel! {
        didSet {
            updateSortingTitleDescription()
        }
    }

    weak var sortingView: SubscriptionsSortingView?
    weak var serversView: ServersListView?
    weak var titleView: SubscriptionsTitleView?
    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

    var assigned = false
    var viewModel = SubscriptionsViewModel()

    var searchText: String = ""

    let socketHandlerToken = String.random(5)

    deinit {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override func viewDidLoad() {
        setupSearchBar()
        setupTitleView()
        updateBackButton()

        super.viewDidLoad()

        viewModel.didUpdateIndexPaths = { [weak self] changes in
            guard let tableView = self?.tableView else {
                return
            }

            let modifications = tableView.indexPathsForVisibleRows?.filter {
                changes.modifications.contains($0) && self?.shouldUpdateCellAt(indexPath: $0) ?? false
            } ?? []

            tableView.beginUpdates()
            tableView.deleteRows(at: changes.deletions, with: .automatic)
            tableView.insertRows(at: changes.insertions, with: .automatic)
            tableView.reloadRows(at: modifications, with: .automatic)
            tableView.endUpdates()
        }

        viewModel.didRebuildSections = { [weak self] in
            self?.tableView?.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        serversView?.frame = frameForDropDownOverlay
        sortingView?.frame = frameForDropDownOverlay
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // This method can stay here, since adding a new connection handler
        // will override the existing one if there's already one. This is here
        // to prevent that some connection issue removes all the connection handler.
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        updateServerInformation()

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }

        viewModel.buildSections()
        tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    // MARK: Storyboard Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Servers" {
            segue.destination.modalPresentationCapturesStatusBarAppearance = true
        }
    }

    // MARK: Setup Views

    func updateBackButton() {
        var unread = 0

        Realm.execute({ (realm) in
            for obj in realm.objects(Subscription.self) {
                unread += obj.unread
            }
        }, completion: { [weak self] in
            self?.navigationItem.backBarButtonItem = UIBarButtonItem(
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
            searchBar = searchController.searchBar
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            if let headerView = tableView.tableHeaderView, searchBar == nil {
                var frame = headerView.frame
                frame.size.height = 88
                headerView.frame = frame

                let searchBar = UISearchBar(frame: CGRect(
                    x: 0,
                    y: 44,
                    width: frame.width,
                    height: 44
                ))

                headerView.addSubview(searchBar)
                self.searchBar = searchBar

                tableView.tableHeaderView = headerView
            }
        }

        self.searchController = searchController
        searchBar?.placeholder = localized("subscriptions.search")
        searchBar?.delegate = self
        searchBar?.applyTheme()
    }

    func setupTitleView() {
        if let titleView = SubscriptionsTitleView.instantiateFromNib() {
            titleView.translatesAutoresizingMaskIntoConstraints = false
            titleView.delegate = self
            titleView.layoutIfNeeded()
            titleView.sizeToFit()
            updateServerInformation()

            // This code can be removed when we drop iOS 10 support.
            titleView.translatesAutoresizingMaskIntoConstraints = true
            navigationItem.titleView = titleView
            self.titleView = titleView

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openServersList))
            titleView.addGestureRecognizer(tapGesture)
        }
    }

}

extension SubscriptionsViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        serversView?.close()
        sortingView?.close()
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            viewModel.searchState = .notSearching
        } else {
            viewModel.searchState = .searching(query: searchText)
        }

        viewModel.buildSections()
        tableView.reloadData()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchState = .notSearching
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""

        viewModel.buildSections()
        tableView.reloadData()
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
        serversView?.close()

        if let sortingView = sortingView {
            sortingView.close()
        } else {
            sortingView = SubscriptionsSortingView.showIn(view)
            sortingView?.delegate = self
            sortingView?.applyTheme()
        }
    }

    @objc func openServersList() {
        sortingView?.close()

        if let serversView = serversView {
            titleView?.updateTitleImage(reverse: false)
            serversView.close()
        } else {
            titleView?.updateTitleImage(reverse: true)
            serversView = ServersListView.showIn(view, frame: frameForDropDownOverlay)
            serversView?.delegate = self
            serversView?.applyTheme()
        }
    }

    private var frameForDropDownOverlay: CGRect {
        var frameHeight = view.bounds.height
        var yOffset: CGFloat = 0.0

        if #available(iOS 11.0, *) {
            frameHeight -= view.safeAreaInsets.top - view.safeAreaInsets.bottom
            yOffset = view.safeAreaInsets.top
        } else {
            let navBarHeight = UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 0.0)
            frameHeight -= navBarHeight
            yOffset = navBarHeight
        }

        return CGRect(x: 0.0, y: yOffset, width: view.bounds.width, height: view.bounds.height)
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
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
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

        if let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath) {
            cell.subscription = subscription
        }

        return cell
    }
}

extension SubscriptionsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(viewModel.heightForHeaderIn(section: section))
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = SubscriptionSectionView.instantiateFromNib() else {
            return nil
        }
        view.setTitle(viewModel.titleForHeaderInSection(section))
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath) else { return }

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

    func shouldUpdateCellAt(indexPath: IndexPath) -> Bool {
        guard
            let index = tableView.indexPathsForVisibleRows?.index(where: { $0 == indexPath }),
            let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath),
            let cell = tableView.visibleCells[index] as? SubscriptionCell
        else {
            return false
        }

        return cell.shouldUpdateForSubscription(subscription)
    }

}

extension SubscriptionsViewController: SubscriptionsTitleViewDelegate {

    func userDidPressServerName() {
        openServersList()
    }

}

extension SubscriptionsViewController: SubscriptionsSortingViewDelegate {

    func updateSortingTitleDescription() {
        if SubscriptionsSortingManager.selectedSortingOption == .alphabetically {
            labelSortingTitleDescription.text = localized("subscriptions.sorting.title.alphabetical")
        } else {
            labelSortingTitleDescription.text = localized("subscriptions.sorting.title.activity")
        }
    }

    func userDidChangeSortingOptions(_ sender: SubscriptionsSortingView) {
        viewModel.buildSections()
        tableView.reloadData()
        updateSortingTitleDescription()
    }

}

extension SubscriptionsViewController: SubscriptionSearchMoreViewDelegate {

    func buttonLoadMoreDidPressed() {
        //viewModel.searchState =
    }

    @IBAction func buttonAddChannelDidTap(sender: Any) {
        performSegue(withIdentifier: "New Channel", sender: sender)
    }

}

extension SubscriptionsViewController: SocketConnectionHandler {

    func socketDidChangeState(state: SocketConnectionState) {
        Log.debug("[SubscriptionsViewController] socketDidChangeState: \(state)")
        titleView?.state = state
    }

}

extension SubscriptionsViewController: ServerListViewDelegate {
    func serverListViewDidClose() {
        titleView?.updateTitleImage(reverse: false)
    }
}

// MARK: Themeable

extension SubscriptionsViewController {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = view.theme else { return }
        filterSeperator?.backgroundColor = theme.mutedAccent
        labelSortingTitleDescription?.textColor = theme.auxiliaryText
        navigationController?.view.backgroundColor = view.theme?.backgroundColor
        searchBar?.applyTheme()

        if serversView != nil {
            titleView?.updateTitleImage(reverse: true)
        } else {
            titleView?.updateTitleImage(reverse: false)
        }
    }
}
