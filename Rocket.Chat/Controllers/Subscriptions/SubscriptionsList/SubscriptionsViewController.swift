//
//  SubscriptionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SwipeCellKit

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

    @IBOutlet weak var viewDirectory: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(recognizeDirectoryTapGesture(_:)))
            viewDirectory.addGestureRecognizer(tapGesture)
        }
    }

    @IBOutlet weak var imageViewDirectory: UIImageView! {
        didSet {
            imageViewDirectory.image = imageViewDirectory.image?.imageWithTint(.RCBlue())
        }
    }

    @IBOutlet weak var labelDirectory: UILabel! {
        didSet {
            labelDirectory.text = localized("directory.title")
        }
    }

    weak var sortingView: SubscriptionsSortingView?
    weak var serversView: ServersListView?
    weak var titleView: SubscriptionsTitleView?
    weak var searchController: UISearchController?
    var searchBar: UISearchBar? {
        return searchController?.searchBar
    }

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

        navigationItem.leftBarButtonItem?.accessibilityLabel = VOLocalizedString("channel.preferences.label")

        // If the device is not using the SplitView, we want to show
        // the 3D Touch preview for the cells
        if splitViewController?.detailViewController as? BaseNavigationController == nil {
            registerForPreviewing(with: self, sourceView: tableView)
        }

        viewModel.didUpdateIndexPaths = { [weak self] changes, completion in
            guard let tableView = self?.tableView else {
                return
            }

            // Update back button title with the number of unreads
            self?.updateBackButton()

            tableView.reload(using: changes, with: .fade, updateRows: { indexPaths in
                for indexPath in indexPaths {
                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false,
                        let cell = tableView.cellForRow(at: indexPath) as? BaseSubscriptionCell {
                        self?.loadContents(for: cell, at: indexPath)
                    }
                }
            }, setData: { completion($0) })
        }

        viewModel.updateVisibleCells = { [weak self] in
            for indexPath in self?.tableView.indexPathsForVisibleRows ?? [] {
                if let cell = self?.tableView.cellForRow(at: indexPath) as? BaseSubscriptionCell {
                    self?.loadContents(for: cell, at: indexPath)
                }
            }
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
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKeyboardFrameWillChange(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func onKeyboardFrameWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            tableView.contentInset.bottom = 0
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.tableView.contentInset.bottom = notification.name == UIResponder.keyboardWillHideNotification ? 0 : keyboardFrameInView.height
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true

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
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchState = .notSearching
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""

        viewModel.buildSections()
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

    @objc func recognizeDirectoryTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard let controller = UIStoryboard(name: "Directory", bundle: Bundle.main).instantiateInitialViewController() else { return }

        if UIDevice.current.userInterfaceIdiom == .pad {
            let nav = BaseNavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .pageSheet

            present(nav, animated: true, completion: nil)
        } else {
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    @objc func recognizeTitleViewTapGesture(_ recognizer: UITapGestureRecognizer) {
        guard #available(iOS 11.0, *) else {
            return toggleServersList()
        }

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
        guard
            serversView == nil &&
            AppManager.supportsMultiServer
        else {
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
        let yOffset = view.safeAreaInsets.top
        frameHeight -= view.safeAreaInsets.top - view.safeAreaInsets.bottom
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

        if let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? MessagesViewController {
            controller.subscription = subscription.managedObject
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
        guard let selectedSubscription = MainSplitViewController.chatViewController?.subscription?.validated() else { return }

        if cell.subscription?.identifier == selectedSubscription.identifier {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.hasLastMessage ? cellForSubscription(at: indexPath) : cellForSubscriptionCondensed(at: indexPath)
        (cell as? SwipeTableViewCell)?.delegate = self

        cell.accessoryType = .none
        return cell
    }

    func cellForSubscription(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as? SubscriptionCell else {
            return UITableViewCell()
        }

        loadContents(for: cell, at: indexPath)

        return cell
    }

    func cellForSubscriptionCondensed(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCellCondensed.identifier) as? SubscriptionCellCondensed else {
            return UITableViewCell()
        }

        loadContents(for: cell, at: indexPath)

        return cell
    }

    func loadContents(for cell: BaseSubscriptionCell, at indexPath: IndexPath) {
        if let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath) {
            cell.subscription = subscription
        }
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
        guard let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath)?.managedObject else { return }

        guard searchController?.searchBar.isFirstResponder == false else {
            searchController?.searchBar.resignFirstResponder()
            searchController?.dismiss(animated: false, completion: {
                self.openChat(for: subscription)
            })

            return
        }

        openChat(for: subscription)
    }

    func openChat(for subscription: Subscription) {
        guard let controller = UIStoryboard.controller(from: "Chat", identifier: "Chat") as? MessagesViewController else {
            return
        }

        controller.subscription = subscription

        // When using iPads, we override the detail controller creating
        // a new instance.
        if parent?.parent?.traitCollection.horizontalSizeClass == .compact {
            guard navigationController?.topViewController == self else {
                return
            }

            navigationController?.pushViewController(controller, animated: true)
        } else {
            let nav = BaseNavigationController(rootViewController: controller)
            splitViewController?.showDetailViewController(nav, sender: self)
        }
    }
}

extension SubscriptionsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {

        guard
            let subscription = viewModel.subscriptionForRowAt(indexPath: indexPath)?.managedObject,
            subscription.open
        else {
            return nil
        }

        switch orientation {
        case .left:
            if !subscription.alert {
                let markUnread = SwipeAction(style: .destructive, title: localized("subscriptions.list.actions.unread")) { _, _ in
                    API.current()?.client(SubscriptionsClient.self).markUnread(subscription: subscription)
                }

                markUnread.backgroundColor = view.theme?.tintColor ?? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                markUnread.image = #imageLiteral(resourceName: "Swipe unread")
                return [markUnread]

            } else {
                let markRead = SwipeAction(style: .destructive, title: localized("subscriptions.list.actions.read")) { _, _ in
                    API.current()?.client(SubscriptionsClient.self).markRead(subscription: subscription)
                }

                markRead.backgroundColor = view.theme?.tintColor ?? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                markRead.image = #imageLiteral(resourceName: "Swipe read")
                return [markRead]
            }

        case .right:
            let hide = SwipeAction(style: .destructive, title: localized("subscriptions.list.actions.hide")) { _, _ in
                API.current()?.client(SubscriptionsClient.self).hideSubscription(subscription: subscription)
            }

            hide.backgroundColor = #colorLiteral(red: 0.3294117647, green: 0.3450980392, blue: 0.368627451, alpha: 1)
            hide.image = #imageLiteral(resourceName: "Swipe hide")

            let favoriteTitle = subscription.favorite ? "subscriptions.list.actions.unfavorite" : "subscriptions.list.actions.favorite"
            let favorite = SwipeAction(style: .default, title: localized(favoriteTitle)) { _, _ in
                API.current()?.client(SubscriptionsClient.self).favoriteSubscription(subscription: subscription)
            }

            favorite.hidesWhenSelected = true
            favorite.backgroundColor = #colorLiteral(red: 1, green: 0.7333333333, blue: 0, alpha: 1)
            favorite.image = subscription.favorite ? #imageLiteral(resourceName: "Swipe unfavorite") : #imageLiteral(resourceName: "Swipe favorite")

            return [hide, favorite]
        }
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .selection
        options.transitionStyle = .border

        if orientation == .left {
            options.backgroundColor = view.theme?.tintColor ?? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
        return options
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

        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
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
