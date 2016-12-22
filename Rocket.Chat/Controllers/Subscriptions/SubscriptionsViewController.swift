//
//  SubscriptionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SideMenu

class SubscriptionsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityViewSearching: UIActivityIndicatorView!
    @IBOutlet weak var textFieldSearch: UITextField! {
        didSet {
            textFieldSearch.placeholder = localizedString("subscriptions.search")
            
            if let placeholder = textFieldSearch.placeholder {
                let color = UIColor(rgb: 0x9AB1BF, alphaVal: 1)
                textFieldSearch.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: color])
            }
        }
    }

    @IBOutlet weak var viewTextField: UIView! {
        didSet {
            viewTextField.layer.cornerRadius = 4
            viewTextField.layer.masksToBounds = true
        }
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

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribeModelChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ChatViewController.sharedInstance()?.toggleStatusBar(hide: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textFieldSearch.resignFirstResponder()
        unregisterKeyboardNotifications()
        ChatViewController.sharedInstance()?.toggleStatusBar(hide: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        registerKeyboardHandlers(tableView)
    }
}

extension SubscriptionsViewController {
    
    func searchBy(_ text: String = "") {
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.filter("name CONTAINS %@", text)
        
        if text.characters.count == 0 {
            isSearchingLocally = false
            isSearchingRemotely = false
            searchResult = []
            
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
        
        let footerView = SubscriptionSearchMoreView.instanceFromNib() as! SubscriptionSearchMoreView
        footerView.delegate = self
        tableView.tableFooterView = footerView
    }
    
    func searchOnSpotlight(_ text: String = "") {
        tableView.tableFooterView = nil
        activityViewSearching.startAnimating()
        
        SubscriptionManager.spotlight(text) { [unowned self] (result) in
            let currentText = self.textFieldSearch.text ?? ""
            
            if currentText.characters.count == 0 {
                return
            }
            
            self.activityViewSearching.stopAnimating()
            self.isSearchingRemotely = true
            self.searchResult = result
            self.groupSubscription()
            self.tableView.reloadData()
        }
    }
    
    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>?) {
        guard !isSearchingLocally && !isSearchingRemotely else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        subscriptions = auth.subscriptions.sorted(byProperty: "lastSeen", ascending: false)
        groupSubscription()
        tableView?.reloadData()
    }
    
    func subscribeModelChanges() {
        guard !assigned else { return }
        guard let auth = AuthManager.isAuthenticated() else { return }
        
        assigned = true
        
        subscriptions = auth.subscriptions.sorted(byProperty: "lastSeen", ascending: false)
        subscriptionsToken = subscriptions?.addNotificationBlock(handleModelUpdates)
        usersToken = try? Realm().addNotificationBlock({ [unowned self] (notification, realm) in
            self.handleModelUpdates(nil)
        })
        
        groupSubscription()
    }
 
    func groupSubscription() {
        var favoriteGroup: [Subscription] = []
        var channelGroup: [Subscription] = []
        var directMessageGroup: [Subscription] = []
        var searchResultsGroup: [Subscription] = []
        
        let orderSubscriptions = isSearchingRemotely ? searchResult : Array(subscriptions!.sorted(byProperty: "name", ascending: true))

        for subscription in orderSubscriptions ?? [] {
            if (isSearchingRemotely) {
                searchResultsGroup.append(subscription)
            }
            
            if !isSearchingLocally && !subscription.open {
                continue
            }
            
            if subscription.favorite {
                favoriteGroup.append(subscription)
                continue
            }
            
            switch subscription.type {
            case .channel, .group:
                channelGroup.append(subscription)
                break
            case .directMessage:
                directMessageGroup.append(subscription)
                break
            }
        }
        
        groupInfomation = [[String: String]]()
        groupSubscriptions = [[Subscription]]()
        
        if (searchResultsGroup.count > 0) {
            groupInfomation?.append([
                "name": String(format: "%@ (%d)", localizedString("subscriptions.search_results"), searchResultsGroup.count)
            ])
            
            searchResultsGroup = searchResultsGroup.sorted {
                return $0.name < $1.name
            }
            
            groupSubscriptions?.append(searchResultsGroup)
        } else {
            if (favoriteGroup.count > 0) {
                groupInfomation?.append([
                    "icon": "Star",
                    "name": String(format: "%@ (%d)", localizedString("subscriptions.favorites"), favoriteGroup.count)
                    ])
                
                favoriteGroup = favoriteGroup.sorted {
                    return $0.type.rawValue < $1.type.rawValue
                }
                
                groupSubscriptions?.append(favoriteGroup)
            }
            
            if (channelGroup.count > 0) {
                groupInfomation?.append([
                    "name": String(format: "%@ (%d)", localizedString("subscriptions.channels"), channelGroup.count)
                    ])
                
                groupSubscriptions?.append(channelGroup)
            }
            
            if (directMessageGroup.count > 0) {
                groupInfomation?.append([
                    "name": String(format: "%@ (%d)", localizedString("subscriptions.direct_messages"), directMessageGroup.count)
                ])
                
                groupSubscriptions?.append(directMessageGroup)
            }
        }
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
        let subscription = groupSubscriptions?[indexPath.section][indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as! SubscriptionCell
        cell.subscription = subscription

        return cell
    }
    
}


extension SubscriptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 50 : 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let group = groupInfomation?[section] else { return nil }
        let view = SubscriptionSectionView.instanceFromNib() as! SubscriptionSectionView
        view.setIconName(group["icon"])
        view.setTitle(group["name"])
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subscription = groupSubscriptions?[indexPath.section][indexPath.row]
        dismiss(animated: true) { 
            ChatViewController.sharedInstance()?.subscription = subscription
        }
    }
    
}


extension SubscriptionsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if string == "\n" {
            if currentText.characters.count > 0 {
                searchOnSpotlight(currentText)
            }

            return false
        }
        
        searchBy(prospectiveText)
        return true
    }
    
}


extension SubscriptionsViewController: SubscriptionSearchMoreViewDelegate {
    
    func buttonLoadMoreDidPressed() {
        searchOnSpotlight(textFieldSearch.text ?? "")
    }
    
}
