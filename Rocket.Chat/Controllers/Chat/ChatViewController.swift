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
        if let nav = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
            return nav.viewControllers.first as? ChatViewController
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSideMenu()
        registerCells()
    }
    
    fileprivate func registerCells() {
        self.collectionView.register(UINib(
            nibName: "ChatTextCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatTextCell.identifier)
    }
    
    fileprivate func scrollToBottom(_ animated: Bool = false) {
        let totalItems = collectionView.numberOfItems(inSection: 0) - 1
        
        if totalItems > 0 {
            let indexPath = IndexPath(row: totalItems, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    
    // MARK: Subscription
    
    fileprivate func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.stop()
        }

        activityIndicator.startAnimating()
        title = subscription?.name
        messages = subscription?.messages.sorted(byProperty: "createdAt", ascending: true)
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
    
    fileprivate func setupSideMenu() {
        let storyboardSubscriptions = UIStoryboard(name: "Subscriptions", bundle: Bundle.main)
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuLeftNavigationController = storyboardSubscriptions.instantiateInitialViewController() as? UISideMenuNavigationController
        
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }
    
}


// MARK: UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages![indexPath.row]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatTextCell.identifier, for: indexPath) as! ChatTextCell
        cell.message = message

        return cell
    }
    
}


extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = messages![indexPath.row]
        let width = UIScreen.main.bounds.size.width
        let height = UILabel.heightForView(message.text, font: UIFont.systemFont(ofSize: 14), width: width - 60) + 35
        return CGSize(width: width, height: max(height, ChatTextCell.minimumHeight))
    }
    
}
