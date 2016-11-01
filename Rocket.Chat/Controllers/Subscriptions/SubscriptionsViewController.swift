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
    
    var assigned = false
    var subscriptions: Results<Subscription>?
    var subscriptionsToken: NotificationToken?
    var usersToken: NotificationToken?
    
    var groupInfomation: [[String: String]]?
    var groupSubscriptions: [List<Subscription>]?
    
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
        let favoriteGroup: List<Subscription> = List<Subscription>()
        let channelGroup: List<Subscription> = List<Subscription>()
        let directMessageGroup: List<Subscription> = List<Subscription>()
        
        for subscription in subscriptions! {
            if (!subscription.open) {
                continue
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
        groupSubscriptions = [List<Subscription>]()
        
        if (favoriteGroup.count > 0) {
            groupInfomation?.append([
                "icon": "Star",
                "name": localizedString("subscriptions.favorites")
            ])

            groupSubscriptions?.append(favoriteGroup)
        }
        
        if (channelGroup.count > 0) {
            groupInfomation?.append([
                "name": localizedString("subscriptions.channels")
            ])

            groupSubscriptions?.append(channelGroup)
        }
        
        if (directMessageGroup.count > 0) {
            groupInfomation?.append([
                "name": localizedString("subscriptions.direct_messages")
            ])

            groupSubscriptions?.append(directMessageGroup)
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
        return section == 0 ? 40 : 60
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
