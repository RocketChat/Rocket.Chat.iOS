//
//  SubscriptionsViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift

class SubscriptionsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var assigned = false
    
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
            return auth.subscriptions.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let auth = AuthManager.isAuthenticated() else {
            return UITableViewCell()
        }

        let subscription = auth.subscriptions[indexPath.row]
        let identifier = "CellSubscription"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier)!
        cell.textLabel?.text = subscription.name
        
        return cell
    }
    
}