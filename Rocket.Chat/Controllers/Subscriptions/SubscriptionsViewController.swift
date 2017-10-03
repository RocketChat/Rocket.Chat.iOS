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

    weak var viewUserMenu: SubscriptionUserStatusView?
    @IBOutlet weak var viewUser: UIView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(viewUserDidTap))
            viewUser.addGestureRecognizer(gesture)
        }
    }

    @IBOutlet weak var labelServer: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
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
    var subscriptions: [Subscription]?
    var subscriptionsToken: NotificationToken?
    var usersToken: NotificationToken?

    var searchText: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = localized("subscriptions.search")
        self.searchController = searchController

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never

            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = true
        } else {
            tableView.tableHeaderView = searchController.searchBar
        }

        if let server = DatabaseManager.servers?[DatabaseManager.selectedIndex] {
            if let imageURL = URL(string: server[ServerPersistKeys.serverIconURL] ?? "") {
                let buttonView = UIView()
                let imageViewServer = UIImageView()
                imageViewServer.translatesAutoresizingMaskIntoConstraints = false
                imageViewServer.sd_setImage(with: imageURL)
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

                let buttonServer = UIBarButtonItem(customView: buttonView)
                navigationItem.leftBarButtonItem = buttonServer
            }
        }

        if let titleView = SubscriptionsTitleView.instantiateFromNib() {
            titleView.user = AuthManager.currentUser()
            navigationItem.titleView = titleView
            self.titleView = titleView
        }

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
        dismissUserMenu()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerKeyboardHandlers(tableView)
    }
}

extension SubscriptionsViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchText = ""
        searchBy()
    }

    func searchBy(_ text: String = "") {
        guard let auth = AuthManager.isAuthenticated() else { return }
//        subscriptions = auth.subscriptions.filterBy(name: text)

        if text.characters.count == 0 {
            isSearchingLocally = false
            isSearchingRemotely = false
            searchResult = []

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

            if currentText.characters.count == 0 {
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

        updateCurrentUserInformation()
        SubscriptionManager.updateUnreadApplicationBadge()

        // TODO: Perform a lighter reload data based on the updated indexes
        tableView?.reloadData()
    }

    func updateCurrentUserInformation() {
        titleView?.user = AuthManager.currentUser()
    }

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let realm = Realm.shared else { return }

        assigned = true

        subscriptionsToken = realm.objects(Subscription.self).addNotificationBlock(handleModelUpdates)
        usersToken = realm.objects(User.self).addNotificationBlock(handleModelUpdates)
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

}

extension SubscriptionsViewController: UITableViewDataSource {

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

        if let controller = UIStoryboard(name: "Chat", bundle: Bundle.main).instantiateInitialViewController() as? ChatViewController {
            controller.subscription = subscription
            navigationController?.pushViewController(controller, animated: true)
        }
    }

}

extension SubscriptionsViewController: UITextFieldDelegate {

    func showCancelSearchButton() {
        searchController?.searchBar.setShowsCancelButton(true, animated: true)
    }

    func hideCancelSearchButton() {
        searchController?.searchBar.setShowsCancelButton(false, animated: true)
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
        searchOnSpotlight(searchController?.searchBar.text ?? "")
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
