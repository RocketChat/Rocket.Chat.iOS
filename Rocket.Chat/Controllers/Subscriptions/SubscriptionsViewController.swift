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
    @IBOutlet weak var buttonCancelSearchWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var textFieldSearch: UITextField! {
        didSet {
            textFieldSearch.placeholder = localized("subscriptions.search")

            if let placeholder = textFieldSearch.placeholder {
                let color = UIColor(rgb: 0x9ea2a4, alphaVal: 1)
                textFieldSearch.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSAttributedStringKey.foregroundColor: color])
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    var subscriptions: Results<Subscription>?
    var subscriptionsToken: NotificationToken?
    var usersToken: NotificationToken?

    var groupInfomation: [[String: String]]?
    var groupSubscriptions: [[Subscription]]?

    var searchText: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeModelChanges()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
            navigationItem.largeTitleDisplayMode = .never

            navigationItem.searchController = UISearchController(searchResultsController: nil)
            navigationItem.hidesSearchBarWhenScrolling = true
        }

        let titleView = SubscriptionsTitleView.instantiateFromNib()
        navigationItem.titleView = titleView
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

//            groupSubscription()
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

//        groupSubscription()
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
//            self?.groupSubscription()
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
//        groupSubscription()
        updateCurrentUserInformation()
        tableView?.reloadData()
    }

    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>?) {
        if isSearchingLocally || isSearchingRemotely {
            updateSearched()
        } else {
            updateAll()
        }

//        groupSubscription()

        updateCurrentUserInformation()
        SubscriptionManager.updateUnreadApplicationBadge()

        // Update titleView information with subscription, can be
        // some status changes
        // if let subscription = ChatViewController.shared?.subscription {
        //     ChatViewController.shared?.chatTitleView?.subscription = subscription
        // }

        // If side panel is visible, reload the data
        // if MainChatViewController.shared?.sidePanelVisible ?? false {
        //     tableView?.reloadData()
        // }
    }

    func updateCurrentUserInformation() {
        
    }

    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let realm = Realm.shared else { return }

        assigned = true

        subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        subscriptionsToken = subscriptions?.addNotificationBlock(handleModelUpdates)
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

}
