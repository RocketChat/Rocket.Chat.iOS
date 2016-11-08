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
    @IBOutlet weak var textFieldSearch: UITextField!
    @IBOutlet weak var viewTextField: UIView! {
        didSet {
            viewTextField.layer.cornerRadius = 4
            viewTextField.layer.masksToBounds = true
        }
    }
    
    var assigned = false
    var isSearching = false
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

extension SubscriptionsViewController {
    
    func searchBy(_ text: String = "") {
        if text.characters.count == 0 {
            self.isSearching = false
            self.searchResult = []
            self.groupSubscription()
            self.tableView.reloadData()
            return
        }
        
        SubscriptionManager.spotlight(text) { [unowned self] (result) in
            self.isSearching = true
            self.searchResult = result
            self.groupSubscription()
            self.tableView.reloadData()
        }
    }
    
    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>?) {
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
        if let subscription = subscriptions?.first {
            ChatViewController.sharedInstance()?.subscription = subscription
        }
        
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
        
        let orderSubscriptions = isSearching ? searchResult : Array(subscriptions!.sorted(byProperty: "name", ascending: true))

        for subscription in orderSubscriptions ?? [] {
            if (isSearching) {
                searchResultsGroup.append(subscription)
            }
            
            if (subscription.favorite) {
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
                    "name": String(format: "%@ (%d)", localizedString("subscriptions.direct_messages"), channelGroup.count)
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
        ChatViewController.sharedInstance()?.subscription = subscription
        dismiss(animated: true, completion: nil)
    }
    
}


extension SubscriptionsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        searchBy(prospectiveText)
        return true
    }
    
}
