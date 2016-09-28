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
        subscriptionsToken = subscriptions?.addNotificationBlock(handleModelUpdates)
        usersToken = try! Realm().objects(User.self).addNotificationBlock(handleModelUpdates)
    }
    
}

extension SubscriptionsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscriptions?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let subscription = subscriptions![indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: SubscriptionCell.identifier) as! SubscriptionCell
        cell.subscription = subscription

        return cell
    }
    
}


extension SubscriptionsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let subscription = subscriptions![indexPath.row]
        ChatViewController.sharedInstance()?.subscription = subscription
        dismiss(animated: true, completion: nil)
    }
    
}
