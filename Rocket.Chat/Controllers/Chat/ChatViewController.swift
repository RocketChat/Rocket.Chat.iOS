//
//  ChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import SideMenu
import RealmSwift
import SlackTextViewController
import URBMediaFocusViewController

class ChatViewController: SLKTextViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    weak var chatTitleView: ChatTitleView?
    weak var chatPreviewModeView: ChatPreviewModeView?
    weak var chatHeaderViewOffline: ChatHeaderViewOffline?
    lazy var mediaFocusViewController = URBMediaFocusViewController()
    
    var dataController = ChatDataController()
    
    var searchResult: [String: Any] = [:]
    
    var hideStatusBar = false
    
    var isRequestingHistory = false
    let socketHandlerToken = String.random(5)
    var messagesToken: NotificationToken!
    var messages: Results<Message>!
    var subscription: Subscription! {
        didSet {
            updateSubscriptionInfo()
            markAsRead()
        }
    }
    
    
    // MARK: View Life Cycle
    
    class func sharedInstance() -> ChatViewController? {
        if let nav = UIApplication.shared.delegate?.window??.rootViewController as? UINavigationController {
            return nav.viewControllers.first as? ChatViewController
        }
        
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor(rgb: 0x5B5B5B, alphaVal: 1)

        mediaFocusViewController.shouldDismissOnTap = true
        mediaFocusViewController.shouldShowPhotoActions = true
        
        isInverted = false
        bounces = true
        shakeToClearEnabled = true
        isKeyboardPanningEnabled = true
        shouldScrollToBottomAfterKeyboardShows = false
        
        rightButton.isEnabled = false
        
        setupTitleView()
        setupSideMenu()
        setupTextViewSettings()
        
        // TODO: this should really goes into the view model, when we have it
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.reconnect), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)
        
        guard let auth = AuthManager.isAuthenticated() else { return }
        let subscriptions = auth.subscriptions.sorted(byProperty: "lastSeen", ascending: false)
        if let subscription = subscriptions.first {
            self.subscription = subscription
        }
        
        view.bringSubview(toFront: activityIndicator)
    }

    internal func reconnect() {
        if !SocketManager.isConnected() {
            SocketManager.reconnect()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let insets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: chatPreviewModeView?.frame.height ?? 0,
            right: 0
        )
        
        collectionView?.contentInset = insets
        collectionView?.scrollIndicatorInsets = insets
    }
    
    fileprivate func setupTextViewSettings() {
        textInputbar.autoHideRightButton = true

        textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("_", withTitle: "Italic")
        textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")
        
        registerPrefixes(forAutoCompletion: ["@", "#"])
    }
    
    fileprivate func setupTitleView() {
        // FIXME: Use typealias or associatedType in the protocol, to avoid casting
        let view = ChatTitleView.instanceFromNib() as? ChatTitleView
        self.navigationItem.titleView = view
        chatTitleView = view
    }
    
    override class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }
    
    fileprivate func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)
        
        collectionView?.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)
        
        autoCompletionView.register(UINib(
            nibName: "AutocompleteCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: AutocompleteCell.identifier)
    }
    
    fileprivate func scrollToBottom(_ animated: Bool = false) {
        let totalItems = collectionView!.numberOfItems(inSection: 0) - 1
        
        if totalItems > 0 {
            let indexPath = IndexPath(row: totalItems, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    
    // MARK: SlackTextViewController
    
    override func canPressRightButton() -> Bool {
        return SocketManager.isConnected()
    }
    
    override func didPressRightButton(_ sender: Any?) {
        sendMessage()
    }
    
    override func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
        sendMessage()
    }
    
    override func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom()
    }
    
    
    // MARK: Message
    
    fileprivate func sendMessage() {
        guard let message = textView.text else { return }
        
        SubscriptionManager.sendTextMessage(message, subscription: subscription) { [unowned self] (response) in
            self.textView.text = ""
        }
    }
    
    
    // MARK: Subscription
    
    fileprivate func markAsRead() {
        SubscriptionManager.markAsRead(subscription) { (response) in
            // Nothing, for now
        }
    }
    
    fileprivate func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.stop()
        }
        
        activityIndicator.startAnimating()
        title = subscription?.name
        chatTitleView?.subscription = subscription
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let indexPaths = dataController.clear()
        collectionView?.performBatchUpdates({ 
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { finished in
            CATransaction.commit()
            
            if self.subscription.isValid() {
                self.updateSubscriptionMessages()
            } else {
                self.subscription.fetchRoomIdentifier({ [unowned self] (response) in
                    self.subscription = response
                })
            }
        })
        
        if subscription.isJoined() {
            setTextInputbarHidden(false, animated: false)
            chatPreviewModeView?.removeFromSuperview()
        } else {
            setTextInputbarHidden(true, animated: false)
            showChatPreviewModeView()
        }
    }
    
    internal func updateSubscriptionMessages() {
        isRequestingHistory = true
    
        messages = subscription.fetchMessages()
        appendMessages(messages: Array(messages))
        
        messagesToken = messages.addNotificationBlock { [unowned self] (changes) in
            if self.isRequestingHistory {
                return
            }
            
            self.appendMessages(messages: Array(self.subscription.fetchMessages()))
        }
        
        MessageManager.getHistory(subscription, lastMessageDate: nil) { [unowned self] (response) in
            DispatchQueue.main.async {
                self.appendMessages(messages: Array(self.subscription.fetchMessages()))
                self.scrollToBottom()
                self.activityIndicator.stopAnimating()
            }
        
            self.isRequestingHistory = false
        }
        
        MessageManager.changes(subscription)
    }
    
    fileprivate func loadMoreMessagesFrom(date: Date?) {
        if isRequestingHistory {
            return
        }
        
        isRequestingHistory = true
        MessageManager.getHistory(subscription, lastMessageDate: date) { [unowned self] (newMessages) in
            DispatchQueue.main.async {
                self.appendMessages(messages: newMessages)
            }

            self.isRequestingHistory = false
        }
    }
    
    fileprivate func appendMessages(messages: Array<Message>) {
        guard let collectionView = self.collectionView else { return }
        
        var objs: [ChatData] = []
        var newMessages: [Message] = []
        
        // Do not add duplicated messages
        for message in messages {
            var insert = true

            for obj in dataController.data {
                if message.identifier == obj.message?.identifier {
                    insert = false
                }
            }
            
            if insert {
                newMessages.append(message)
            }
        }
        
        // Normalize data into ChatData object
        for message in newMessages {
            var obj = ChatData(type: .message, timestamp: message.createdAt!)!
            obj.message = message
            objs.append(obj)
        }
        
        // No new data? Don't update it then
        if objs.count == 0 {
            return
        }
        
        // Insert data into collectionView without moving it
        let indexPaths = dataController.insert(objs)
        let contentHeight = collectionView.contentSize.height
        let offsetY = collectionView.contentOffset.y
        let bottomOffset = contentHeight - offsetY
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        collectionView.performBatchUpdates({
            collectionView.insertItems(at: indexPaths)
        }, completion: { finished in
            collectionView.contentOffset = CGPoint(x: 0, y: collectionView.contentSize.height - bottomOffset)
            CATransaction.commit()
        })
    }
    
    fileprivate func showChatPreviewModeView() {
        chatPreviewModeView?.removeFromSuperview()

        let previewView = ChatPreviewModeView.instanceFromNib() as! ChatPreviewModeView
        previewView.delegate = self
        previewView.subscription = subscription
        previewView.frame = CGRect(x: 0, y: view.frame.height - previewView.frame.height, width: view.frame.width, height: previewView.frame.height)
        view.addSubview(previewView)
        chatPreviewModeView = previewView
    }
    

    // MARK: IBAction
    
    @IBAction func buttonMenuDidPressed(_ sender: AnyObject) {
        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
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


// MARK: Status Bar Control

extension ChatViewController {
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    func toggleStatusBar(hide: Bool) {
        hideStatusBar = hide
        UIView.animate(withDuration: 0.25) { () -> Void in
            self.setNeedsStatusBarAppearanceUpdate()
            self.navigationController?.navigationBar.frame.origin.y = 20
            self.collectionView?.frame.origin.y = 0
        }
    }
    
}


// MARK: UICollectionViewDataSource

extension ChatViewController {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let message = dataController.itemAt(indexPath)?.message {
                loadMoreMessagesFrom(date: message.createdAt)
            } else {
                let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)

                if let message = dataController.itemAt(nextIndexPath)?.message {
                    loadMoreMessagesFrom(date: message.createdAt)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataController.data.count > indexPath.row else { return UICollectionViewCell() }
        guard let obj = dataController.itemAt(indexPath) else { return UICollectionViewCell() }
        
        if obj.type == .message {
            return cellForMessage(obj, at: indexPath)
        }
        
        if obj.type == .daySeparator {
            return cellForDaySeparator(obj, at: indexPath)
        }
        
        return UICollectionViewCell()
    }
    
    
    // MARK: Cells
    
    func cellForMessage(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCell(
            withReuseIdentifier: ChatMessageCell.identifier,
            for: indexPath
        ) as! ChatMessageCell
        
        cell.delegate = self
        
        if let message = obj.message {
            cell.message = message
        }
        
        return cell
    }
    
    func cellForDaySeparator(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView!.dequeueReusableCell(
            withReuseIdentifier: ChatMessageDaySeparator.identifier,
            for: indexPath
        ) as! ChatMessageDaySeparator
        
        cell.labelTitle.text = obj.timestamp.formatted("MMM dd, YYYY")
        return cell
    }

}



// MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = UIScreen.main.bounds.size.width
    
        if let message = dataController.itemAt(indexPath)?.message {
            let height = ChatMessageCell.cellMediaHeightFor(message: message)
            return CGSize(width: fullWidth, height: height)
        }
        
        return CGSize(width: fullWidth, height: 40)
    }
    
}


// MARK: ChatPreviewModeViewProtocol

extension ChatViewController: ChatPreviewModeViewProtocol {
    
    func userDidJoinedSubscription() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let subscription = self.subscription else { return }
        
        Realm.execute { (realm) in
            subscription.auth = auth
        }
        
        self.subscription = subscription
    }
    
}

