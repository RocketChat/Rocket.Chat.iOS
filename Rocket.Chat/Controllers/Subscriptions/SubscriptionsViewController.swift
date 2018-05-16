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

    weak var titleView: SubscriptionsTitleView?
    weak var searchController: UISearchController?
    weak var searchBar: UISearchBar?

    var assigned = false
    var isSearchingLocally = false
    var isSearchingRemotely = false
    var searchResult: [Subscription]?
    var subscriptions: Results<Subscription>?
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

        updateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateData()
        tableView?.reloadData()

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    // MARK: Storyboard Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.modalPresentationCapturesStatusBarAppearance = true
    }

    // MARK: Subscriptions

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let realm = Realm.current else { return }

        assigned = true

        subscriptions = auth.subscriptions.sortedByLastMessageDate()
        subscriptionsToken = subscriptions?.observe(handleSubscriptionUpdates)

        if let currentUserIdentifier = AuthManager.currentUser()?.identifier {
            let query = realm.objects(User.self).filter("identifier = %@", currentUserIdentifier)
            currentUserToken = query.observe(handleCurrentUserUpdates)
        }
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
            let imageViewServer = UIImageView()

            if let imageURL = URL(string: server[ServerPersistKeys.serverIconURL] ?? "") {
                imageViewServer.sd_setImage(with: imageURL)
            } else {
                imageViewServer.image = UIImage(named: "User")
            }

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
        subscriptions = auth.subscriptions.sortedByLastMessageDate().filterBy(name: text)
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

        API.current()?.client(SpotlightClient.self).search(query: text) { [weak self] result in
            let currentText = self?.textFieldSearch.text ?? ""

            if currentText.count == 0 {
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
        subscriptions = auth.subscriptions.sortedByLastMessageDate()
    }

    func updateSearched() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sortedByLastMessageDate().filterBy(name: searchText)
    }

    func updateSubscriptionsList() {
        DispatchQueue.main.async {
            let visibleRows = self.tableView.indexPathsForVisibleRows ?? []

            self.updateBackButton()

            // If the list were empty, let's just refresh everything.
            if visibleRows.count == 0 {
                self.tableView.reloadData()
                return
            }

            for indexPath in visibleRows {
                if let subscriptionCell = self.tableView.cellForRow(at: indexPath) as? SubscriptionCell {
                    subscriptionCell.subscription = self.subscriptions?[indexPath.row]
                }
            }
        }
    }

    func updateData() {
        guard !isSearchingLocally && !isSearchingRemotely else { return }

        updateAll()
        updateCurrentUserInformation()
        updateSubscriptionsList()
    }

    func handleCurrentUserUpdates<T>(changes: RealmCollectionChange<Results<T>>?) {
        updateCurrentUserInformation()
    }

    func handleSubscriptionUpdates<T>(changes: RealmCollectionChange<Results<T>>?) {
        updateSubscriptionsList()
    }

    func updateCurrentUserInformation() {
        titleView?.user = AuthManager.currentUser()
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
        // performSegue(withIdentifier: "User", sender: nil)
    }

}

extension SubscriptionsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 71
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

        // When using iPads, we override the detail controller creating
        // a new instance.
        if let _ = splitViewController?.detailViewController as? BaseNavigationController {
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

extension SubscriptionsViewController: SubscriptionSearchMoreViewDelegate {

    func buttonLoadMoreDidPressed() {
        searchOnSpotlight(searchController?.searchBar.text ?? "")
    }

    @IBAction func buttonAddChannelDidTap(sender: Any) {
        performSegue(withIdentifier: "New Channel", sender: sender)
    }

}
