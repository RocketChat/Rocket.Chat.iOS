//
//  ChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SlackTextViewController
import URBMediaFocusViewController

// swiftlint:disable file_length type_body_length
final class ChatViewController: SLKTextViewController {

    var activityIndicator: LoaderView!
    @IBOutlet weak var activityIndicatorContainer: UIView! {
        didSet {
            let width = activityIndicatorContainer.bounds.width
            let height = activityIndicatorContainer.bounds.height
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let activityIndicator = LoaderView(frame: frame)
            activityIndicatorContainer.addSubview(activityIndicator)
            self.activityIndicator = activityIndicator
        }
    }

    @IBOutlet weak var buttonScrollToBottom: UIButton!
    var buttonScrollToBottomMarginConstraint: NSLayoutConstraint?

    weak var chatTitleView: ChatTitleView?
    weak var chatPreviewModeView: ChatPreviewModeView?
    weak var chatHeaderViewOffline: ChatHeaderViewOffline?
    lazy var mediaFocusViewController = URBMediaFocusViewController()

    var dataController = ChatDataController()

    var searchResult: [String: Any] = [:]

    var closeSidebarAfterSubscriptionUpdate = false

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

    weak var delegate: ChatViewControllerDelegate?

    // MARK: View Life Cycle

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

        leftButton.setImage(UIImage(named: "Upload"), for: .normal)

        rightButton.isEnabled = false

        setupTitleView()
        setupTextViewSettings()
        setupScrollToBottomButton()

        // TODO: this should really goes into the view model, when we have it
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.reconnect), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        guard let auth = AuthManager.isAuthenticated() else { return }
        let subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        if let subscription = subscriptions.first {
            self.subscription = subscription
        }

        view.bringSubview(toFront: activityIndicatorContainer)
        view.bringSubview(toFront: buttonScrollToBottom)
        view.bringSubview(toFront: textInputbar)
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, segue.identifier == "Channel Info" {
            if let controller = nav.viewControllers.first as? ChannelInfoViewController {
                if let subscription = self.subscription {
                    controller.subscription = subscription
                }
            }
        }
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
        let view = ChatTitleView.instantiateFromNib()
        self.navigationItem.titleView = view
        chatTitleView = view

        let gesture = UITapGestureRecognizer(target: self, action: #selector(chatTitleViewDidPressed))
        chatTitleView?.addGestureRecognizer(gesture)
    }

    fileprivate func setupScrollToBottomButton() {
        buttonScrollToBottom.layer.cornerRadius = 25
        buttonScrollToBottom.layer.borderColor = UIColor.lightGray.cgColor
        buttonScrollToBottom.layer.borderWidth = 1
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
        let boundsHeight = collectionView?.bounds.size.height ?? 0
        let sizeHeight = collectionView?.contentSize.height ?? 0
        let offset = CGPoint(x: 0, y: max(sizeHeight - boundsHeight, 0))
        collectionView?.setContentOffset(offset, animated: animated)
        hideButtonScrollToBottom(animated: true)
    }

    fileprivate func hideButtonScrollToBottom(animated: Bool) {
        buttonScrollToBottomMarginConstraint?.constant = 50
        let action = {
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.5, animations: action)
        } else {
            action()
        }
    }

    // MARK: SlackTextViewController

    override func canPressRightButton() -> Bool {
        return SocketManager.isConnected()
    }

    override func didPressRightButton(_ sender: Any?) {
        sendMessage()
    }

    override func didPressLeftButton(_ sender: Any?) {
        buttonUploadDidPressed()
    }

    override func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
        sendMessage()
    }

    override func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom()
    }

    // MARK: Message

    fileprivate func sendMessage() {
        guard let messageText = textView.text, messageText.characters.count > 0 else { return }

        rightButton.isEnabled = false

        var message: Message?
        Realm.executeOnMainThread({ (realm) in
            message = Message()
            message?.internalType = ""
            message?.createdAt = Date()
            message?.text = messageText
            message?.subscription = self.subscription
            message?.identifier = String.random(18)
            message?.temporary = true
            message?.user = AuthManager.currentUser()

            if let message = message {
                realm.add(message)
            }
        })

        if let message = message {
            textView.text = ""
            rightButton.isEnabled = true

            SubscriptionManager.sendTextMessage(message) { _ in
                Realm.executeOnMainThread({ (realm) in
                    message.temporary = false
                    realm.add(message, update: true)
                })
            }
        }
    }

    // MARK: Subscription

    fileprivate func markAsRead() {
        SubscriptionManager.markAsRead(subscription) { _ in
            // Nothing, for now
        }
    }

    internal func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.stop()
        }

        title = subscription?.name
        chatTitleView?.subscription = subscription
        textView.resignFirstResponder()

        collectionView?.performBatchUpdates({
            let indexPaths = self.dataController.clear()
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { _ in
            CATransaction.commit()
            self.delegate?.chatViewController(self, didUpdateWithSubscription: self.subscription)
        })

        if self.subscription.isValid() {
            self.updateSubscriptionMessages()
        } else {
            self.subscription.fetchRoomIdentifier({ [weak self] response in
                self?.subscription = response
            })
        }

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
        messagesToken?.stop()
        messagesToken = messages.addNotificationBlock { [weak self] changes in
            switch changes {
            case .initial(let messages):
                self?.appendMessages(messages: Array(messages), updateScrollPosition: false, completion: {
                    guard let messages = self?.messages else { return }

                    if messages.count == 0 {
                        self?.activityIndicator.startAnimating()
                    } else {
                        self?.scrollToBottom()
                    }
                })

                break
            case .update(_, _, let insertions, let modifications):
                guard let messages = self?.subscription.fetchMessages() else { return }

                if insertions.count > 0 {
                    self?.appendMessages(messages: Array(messages), updateScrollPosition: true, completion: nil)
                }

                self?.collectionView?.performBatchUpdates({
                    var indexPathModifications = [Int]()
                    for modified in modifications {
                        if let index = self?.dataController.update(messages[modified]) {
                            if index >= 0 {
                                indexPathModifications.append(index)
                            }
                        }
                    }

                    self?.collectionView?.reloadItems(at: indexPathModifications.map { IndexPath(row: $0, section: 0) })
                }, completion: nil)

                break
            case .error:
                break
            }
        }

        MessageManager.getHistory(subscription, lastMessageDate: nil) { [weak self] in
            guard let messages = self?.subscription.fetchMessages() else { return }

            self?.appendMessages(messages: Array(messages), updateScrollPosition: false, completion: {
                self?.activityIndicator.stopAnimating()

                UIView.performWithoutAnimation {
                    self?.scrollToBottom()
                }

                self?.isRequestingHistory = false
            })
        }

        MessageManager.changes(subscription)
    }

    fileprivate func loadMoreMessagesFrom(date: Date?) {
        if isRequestingHistory {
            return
        }

        isRequestingHistory = true
        MessageManager.getHistory(subscription, lastMessageDate: date) { [weak self] in
            guard let messages = self?.subscription.fetchMessages() else { return }
            self?.appendMessages(messages: Array(messages), updateScrollPosition: true, completion: nil)
            self?.isRequestingHistory = false
        }
    }

    fileprivate func appendMessages(messages: [Message], updateScrollPosition: Bool = false, completion: VoidCompletion?) {
        guard let collectionView = self.collectionView else { return }

        var contentHeight = collectionView.contentSize.height
        var offsetY = collectionView.contentOffset.y
        var bottomOffset = contentHeight - offsetY

        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({
                // Insert data into collectionView without moving it
                contentHeight = collectionView.contentSize.height
                offsetY = collectionView.contentOffset.y
                bottomOffset = contentHeight - offsetY

                var objs: [ChatData] = []
                var newMessages: [Message] = []

                // Do not add duplicated messages
                for message in messages {
                    var insert = true

                    // swiftlint:disable for_where
                    for obj in self.dataController.data {
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
                    guard let createdAt = message.createdAt else { continue }
                    guard var obj = ChatData(type: .message, timestamp: createdAt) else { continue }
                    obj.message = message
                    objs.append(obj)
                }

                // No new data? Don't update it then
                if objs.count == 0 {
                    return
                }

                let indexPaths = self.dataController.insert(objs)
                collectionView.insertItems(at: indexPaths)
            }, completion: { _ in
                let shouldScroll = self.isContentBiggerThanContainerHeight()
                if updateScrollPosition && shouldScroll {
                    let offset = CGPoint(x: 0, y: collectionView.contentSize.height - bottomOffset)
                    collectionView.contentOffset = offset
                }

                DispatchQueue.main.async {
                    completion?()
                }
            })
        }
    }

    fileprivate func showChatPreviewModeView() {
        chatPreviewModeView?.removeFromSuperview()

        if let previewView = ChatPreviewModeView.instantiateFromNib() {
            previewView.delegate = self
            previewView.subscription = subscription
            previewView.frame = CGRect(x: 0, y: view.frame.height - previewView.frame.height, width: view.frame.width, height: previewView.frame.height)
            view.addSubview(previewView)
            chatPreviewModeView = previewView
        }
    }

    fileprivate func isContentBiggerThanContainerHeight() -> Bool {
        if let contentHeight = self.collectionView?.contentSize.height {
            if let collectionViewHeight = self.collectionView?.frame.height {
                if contentHeight < collectionViewHeight {
                    return false
                }
            }
        }

        return true
    }

    // MARK: IBAction

    func chatTitleViewDidPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "Channel Info", sender: sender)
    }

    @IBAction func buttonScrollToBottomPressed(_ sender: UIButton) {
        scrollToBottom(true)
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
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatMessageCell.identifier,
            for: indexPath
            ) as? ChatMessageCell else {
                return UICollectionViewCell()
        }

        cell.delegate = self

        if let message = obj.message {
            cell.message = message
        }

        return cell
    }

    func cellForDaySeparator(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatMessageDaySeparator.identifier,
            for: indexPath
        ) as? ChatMessageDaySeparator else {
                return UICollectionViewCell()
        }
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

// MARK: UIScrollViewDelegate

extension ChatViewController {

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let view = buttonScrollToBottom.superview else { return }

        if buttonScrollToBottomMarginConstraint == nil {
            buttonScrollToBottomMarginConstraint = buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
            buttonScrollToBottomMarginConstraint?.isActive = true
        }
        if targetContentOffset.pointee.y < scrollView.contentSize.height - scrollView.frame.height {
            buttonScrollToBottomMarginConstraint?.constant = -64
            UIView.animate(withDuration: 0.5) {
                view.layoutIfNeeded()
            }
        } else {
            hideButtonScrollToBottom(animated: true)
        }
    }

}

// MARK: ChatPreviewModeViewProtocol

extension ChatViewController: ChatPreviewModeViewProtocol {

    func userDidJoinedSubscription() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let subscription = self.subscription else { return }

        Realm.executeOnMainThread({ _ in
            subscription.auth = auth
        })

        self.subscription = subscription
    }

}
