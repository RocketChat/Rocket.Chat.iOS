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
    
    func handleModelUpdates<T>(_: RealmCollectionChange<RealmSwift.Results<T>>) {
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
        usersToken = try! Realm().objects(User.self).addNotificationBlock(handleModelUpdates)
        
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
            case .channel,
                 .group:
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
            groupInfomation?.append(["name": "Favorites"])
            groupSubscriptions?.append(favoriteGroup)
        }
        
        if (channelGroup.count > 0) {
            groupInfomation?.append(["name": "Channels"])
            groupSubscriptions?.append(channelGroup)
        }
        
        if (directMessageGroup.count > 0) {
            groupInfomation?.append(["name": "Direct Messages"])
            groupSubscriptions?.append(directMessageGroup)
        }
    }

}

//extension SubscriptionsViewController: UITableViewDataSource {
//	
//	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//		return groupInfomation?.count ?? 0
//	}
//	
//	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//		return groupInfomation?[section]["name"] ?? ""
//	}
//	
//	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//		return groupSubscriptions?[section].count ?? 0
//	}
//	
//	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//		let subscription = groupSubscriptions?[indexPath.section][indexPath.row]
//		
//		let cell = tableView.dequeueReusableCellWithIdentifier(SubscriptionCell.identifier) as! SubscriptionCell
//		cell.subscription = subscription
//		
//		return cell
//	}
//	
//}

extension SubscriptionsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupInfomation?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupInfomation?[section]["name"] ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupSubscriptions?[section].count ?? 0 //subscriptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let subscription = subscriptions![indexPath.row]
        let subscription = groupSubscriptions?[indexPath.section][indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as! SubscriptionCell
        cell.subscription = subscription

        return cell
    }
    
}


extension SubscriptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let subscription = subscriptions![indexPath.row]
        let subscription = groupSubscriptions?[indexPath.section][indexPath.row]
        ChatViewController.sharedInstance()?.subscription = subscription
        dismiss(animated: true, completion: nil)
    }
    
}
