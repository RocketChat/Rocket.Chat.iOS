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
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        setupSearchBar()
        setupTitleView()
        updateBackButton()
        startObservingKeyboard()

        super.viewDidLoad()

        // If the device is not using the SplitView, we want to show
        // the 3D Touch preview for the cells
        if splitViewController?.detailViewController as? BaseNavigationController == nil {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        viewModel.didUpdateIndexPaths = { [weak self] changes in
            guard let tableView = self?.tableView else {
                return
            }

            // Update back button title with the number of unreads
            self?.updateBackButton()

            // If there's no changes, let's not proceed.
            if (changes.insertions.count + changes.deletions.count + changes.modifications.count) == 0 {
                return
            }

            // Update TableView data if there's any change in the data
            if self?.viewModel.numberOfSections ?? 2 > 1 {
                tableView.reloadData()
            } else {
                if #available(iOS 11.0, *) {
                    tableView.performBatchUpdates({
                        tableView.deleteRows(at: changes.deletions, with: .automatic)
                        tableView.insertRows(at: changes.insertions, with: .automatic)
                        tableView.reloadRows(at: changes.modifications, with: .none)
                    }, completion: nil)
                } else {
                    tableView.beginUpdates()
                    tableView.deleteRows(at: changes.deletions, with: .automatic)
                    tableView.insertRows(at: changes.insertions, with: .automatic)
                    tableView.reloadRows(at: changes.modifications, with: .none)
                    tableView.endUpdates()
                }
            }
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
        titleView?.state = SocketManager.sharedInstance.state
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !(searchBar?.text?.isEmpty ?? true) {
            searchBar?.perform(#selector(becomeFirstResponder), with: nil, afterDelay: 0.1)
        }
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

    // MARK: Keyboard

    private func startObservingKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKeyboardFrameWillChange(_:)),
            name: Notification.Name.UIKeyboardWillChangeFrame,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKeyboardFrameWillChange(_:)),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    @objc private func onKeyboardFrameWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            tableView.contentInset.bottom = 0
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let animationDuration: TimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIViewAnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.tableView.contentInset.bottom = notification.name == Notification.Name.UIKeyboardWillHide ? 0 : keyboardFrameInView.height
        }, completion: nil)
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
        searchController.hidesNavigationBarDuringPresentation = UIDevice.current.userInterfaceIdiom != .pad

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
            titleView.layoutIfNeeded()
            titleView.sizeToFit()
            updateServerInformation()

            // This code can be removed when we drop iOS 10 support.
            titleView.translatesAutoresizingMaskIntoConstraints = true
            navigationItem.titleView = titleView
            self.titleView = titleView

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(recognizeTitleViewTapGesture(_:)))
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

    private func shouldRespondToTap(recognizer: UITapGestureRecognizer, inset: CGFloat) -> Bool {
        guard
            let view = recognizer.view,
            recognizer.state == .ended
        else {
            return false
        }
        let tapLocation = recognizer.location(in: view).y
        return tapLocation > inset && tapLocation < view.bounds.height - inset
    }

    // MARK: IBAction

    @IBAction func recognizeSortingHeaderTapGesture(_ recognizer: UITapGestureRecognizer) {
        if shouldRespondToTap(recognizer: recognizer, inset: 8) {
            toggleSortingView()
        }
    }

    @objc func recognizeTitleViewTapGesture(_ recognizer: UITapGestureRecognizer) {
        if shouldRespondToTap(recognizer: recognizer, inset: 6) {
            toggleServersList()
        }
    }

    func toggleSortingView() {
        serversView?.close()

        if let sortingView = sortingView {
            sortingView.close()
        } else {
            sortingView = SubscriptionsSortingView.showIn(view)
            sortingView?.delegate = self
        }
    }

    func toggleServersList() {
        if serversView != nil {
            closeServersList()
        } else {
            openServersList()
        }
    }

    func openServersList() {
        guard serversView == nil else {
            return
        }

        sortingView?.close()

        titleView?.updateTitleImage(reverse: true)
        serversView = ServersListView.showIn(view, frame: frameForDropDownOverlay)
        serversView?.delegate = self
    }

    func closeServersList() {
        guard let serversView = serversView else {
            return
        }

        titleView?.updateTitleImage(reverse: false)
        serversView.close()
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

// MARK: UIViewControllerPreviewingDelegate

extension SubscriptionsViewController: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath),
            let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath)
        else {
            return nil
        }

        previewingContext.sourceRect = cell.frame

        if let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? ChatViewController {
            controller.subscription = subscription
            return controller
        }

        return nil
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SubscriptionCellProtocol else { return }
        guard let subscription = cell.subscription?.validated() else { return }
        guard let selectedSubscription = MainSplitViewController.chatViewController?.subscription?.validated() else { return }

        if subscription.identifier == selectedSubscription.identifier {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.hasLastMessage ? cellForSubscription(at: indexPath) : cellForSubscriptionCondensed(at: indexPath)

        if UIDevice.current.userInterfaceIdiom == .pad {
            cell.accessoryType = .none
        } else {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    func cellForSubscription(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as? SubscriptionCell else {
            return UITableViewCell()
        }

        if let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath) {
            cell.subscription = subscription
        }

        return cell
    }

    func cellForSubscriptionCondensed(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCellCondensed.identifier) as? SubscriptionCellCondensed else {
            return UITableViewCell()
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
        onSelectRowAt(indexPath)
    }

    func onSelectRowAt(_ indexPath: IndexPath) {
        guard let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath) else { return }

        searchController?.searchBar.resignFirstResponder()

        openChat(for: subscription)
    }

    func openChat(for subscription: Subscription) {
        guard let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? ChatViewController else {
            return
        }

        // When using iPads, we override the detail controller creating
        // a new instance.
        if parent?.parent?.traitCollection.horizontalSizeClass == .compact {
            controller.subscription = subscription
            navigationController?.pushViewController(controller, animated: true)
        } else {
            controller.subscription = subscription

            let nav = BaseNavigationController(rootViewController: controller)
            splitViewController?.showDetailViewController(nav, sender: self)
        }
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

    func userDidChangeSortingOptions() {
        let selectedSortingOption = SubscriptionsSortingManager.selectedSortingOption.rawValue
        let selectedGroupingOptions = SubscriptionsSortingManager.selectedGroupingOptions.map {$0.rawValue}

        AnalyticsManager.log(
            event: .updatedSubscriptionSorting(
                sorting: selectedSortingOption,
                grouping: selectedGroupingOptions.joined(separator: " | ")
            )
        )

        viewModel.buildSections()
        updateSortingTitleDescription()
        tableView.reloadData()
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

        navigationController?.view.backgroundColor = theme.backgroundColor
        searchBar?.applyTheme()

        if serversView != nil {
            titleView?.updateTitleImage(reverse: true)
        } else {
            titleView?.updateTitleImage(reverse: false)
        }
    }
}

// MARK: Room Selection Helpers

extension SubscriptionsViewController {
    func selectRoomAt(_ index: Int) {
        guard
            let indexPath = viewModel.indexPathForAbsoluteIndex(index),
            indexPath.row >= 0 && indexPath.section >= 0
        else {
            return
        }

        onSelectRowAt(indexPath)

        DispatchQueue.main.async { [weak self] in
            self?.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func selectNextRoom() {
        if let indexPath = tableView.indexPathsForSelectedRows?.first {
            selectRoomAt(viewModel.absoluteIndexForIndexPath(indexPath) + 1)
        }
    }

    func selectPreviousRoom() {
        if let indexPath = tableView.indexPathsForSelectedRows?.first {
            selectRoomAt(viewModel.absoluteIndexForIndexPath(indexPath) - 1)
        }
    }
}
