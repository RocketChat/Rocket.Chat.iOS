//
//  ChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import SideMenu
import RealmSwift

class ChatViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var messagesToken: NotificationToken!
    var messages: Results<Message>!
    var subscription: Subscription! {
        didSet {
            updateSubscriptionInfo()
        }
    }
    
    
    // MARK: View Life Cycle
    
    class func sharedInstance() -> ChatViewController? {
        if let nav = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UINavigationController {
            return nav.viewControllers.first as? ChatViewController
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSideMenu()
        registerCells()
    }
    
    private func registerCells() {
        self.collectionView.registerNib(UINib(
            nibName: "ChatTextCell",
            bundle: NSBundle.mainBundle()
        ), forCellWithReuseIdentifier: ChatTextCell.identifier)
    }
    
    private func scrollToBottom(animated: Bool = false) {
        let totalItems = collectionView.numberOfItemsInSection(0) - 1
        
        if totalItems > 0 {
            let indexPath = NSIndexPath(forRow: totalItems, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    
    // MARK: Subscription
    
    private func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.stop()
        }

        activityIndicator.startAnimating()
        title = subscription?.name
        messages = subscription?.messages.sorted("createdAt", ascending: true)
        messagesToken = messages.addNotificationBlock { [unowned self] (changes) in
            if self.messages.count > 0 {
                self.activityIndicator.stopAnimating()
            }

            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.scrollToBottom()
        }
        
        MessageManager.getHistory(subscription) { [unowned self] (response) in
            self.activityIndicator.stopAnimating()
            self.messages = self.subscription?.fetchMessages()
            self.collectionView.reloadData()
            self.collectionView.layoutIfNeeded()
            self.scrollToBottom()
        }
        
        MessageManager.changes(subscription)
    }
    
    
    // MARK: Side Menu
    
    private func setupSideMenu() {
        let storyboardSubscriptions = UIStoryboard(name: "Subscriptions", bundle: NSBundle.mainBundle())
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuLeftNavigationController = storyboardSubscriptions.instantiateInitialViewController() as? UISideMenuNavigationController
        
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }
    
}


// MARK: UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let message = messages![indexPath.row]

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ChatTextCell.identifier, forIndexPath: indexPath) as! ChatTextCell
        cell.message = message

        return cell
    }
    
}


extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let message = messages![indexPath.row]
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UILabel.heightForView(message.text, font: UIFont.systemFontOfSize(14), width: width - 60) + 35
        return CGSize(width: width, height: max(height, ChatTextCell.minimumHeight))
    }
    
}
