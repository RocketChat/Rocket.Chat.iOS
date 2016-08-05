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
    var subscriptions: Results<Subscription>!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if !assigned {
            if let auth = AuthManager.isAuthenticated() {
                assigned = true

                SubscriptionManager.changes(auth, completion: { [unowned self] (response) in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
}

extension SubscriptionsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let auth = AuthManager.isAuthenticated() {
            subscriptions = auth.subscriptions.sorted("lastSeen", ascending: false)
            return subscriptions.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let subscription = subscriptions[indexPath.row]

        let cell = tableView.dequeueReusableCellWithIdentifier(SubscriptionCell.identifier) as! SubscriptionCell
        cell.subscription = subscription

        return cell
    }
    
}


extension SubscriptionsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subscription = subscriptions[indexPath.row]
        ChatViewController.sharedInstance()?.subscription = subscription
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}