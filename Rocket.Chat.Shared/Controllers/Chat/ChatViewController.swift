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

enum MessageCellStyle {
    case normal
    case bubble
}

// swiftlint:disable file_length type_body_length
public class ChatViewController: SLKTextViewController, AuthManagerInjected, SocketManagerInjected, SubscriptionManagerInjected, MessageManagerInjected {

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
    weak var chatHeaderViewStatus: ChatHeaderViewStatus?
    lazy var mediaFocusViewController = URBMediaFocusViewController()
    var documentController: UIDocumentInteractionController?

    var dataController = ChatDataController()

    var searchResult: [String: Any] = [:]

    var isRequestingHistory = false

    let socketHandlerToken = String.random(5)
    var messagesToken: NotificationToken!
    var messagesQuery: Results<Message>!
    var messages: [Message] = []
    var subscription: Subscription! {
        didSet {
            updateSubscriptionInfo()
            markAsRead()
        }
    }
    var messageCellStyle: MessageCellStyle = .normal {
        didSet {
            collectionView?.reloadData()
        }
    }

    // MARK: View Life Cycle

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        socketManager.removeConnectionHandler(token: socketHandlerToken)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor(rgb: 0x5B5B5B, alphaVal: 1)

        mediaFocusViewController.shouldDismissOnTap = true
        mediaFocusViewController.shouldShowPhotoActions = true

        collectionView?.isPrefetchingEnabled = true

        isInverted = false
        bounces = true
        shakeToClearEnabled = true
        isKeyboardPanningEnabled = true
        shouldScrollToBottomAfterKeyboardShows = false

        leftButton.setImage(UIImage(named: "Upload", in: Bundle.rocketChat, compatibleWith: nil), for: .normal)

        rightButton.isEnabled = false

        setupTitleView()
        setupTextViewSettings()
        setupScrollToBottomButton()

        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.reconnect), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

        view.bringSubview(toFront: activityIndicatorContainer)
        view.bringSubview(toFront: buttonScrollToBottom)
        view.bringSubview(toFront: textInputbar)

        socketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        guard self.subscription == nil else { return }
        guard let auth = authManager.isAuthenticated() else { return }
        let subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        if let subscription = subscriptions.first {
            self.subscription = subscription
        }
    }

    internal func reconnect() {
        if !socketManager.isConnected() {
            socketManager.reconnect()
        }
    }

    override public func viewWillLayoutSubviews() {
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

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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

    override public class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
        return ChatCollectionViewFlowLayout()
    }

    fileprivate func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatLoaderCell",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatLoaderCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)

        collectionView?.register(UINib(
            nibName: "ReceivedMessageBubble",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatMessageBubbleCell.receivedIdentifier)
        collectionView?.register(UINib(
            nibName: "SentMessageBubble",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatMessageBubbleCell.sentIdendifier)
        collectionView?.register(UINib(
            nibName: "ChatChannelHeaderCell",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatChannelHeaderCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatDirectMessageHeaderCell",
            bundle: Bundle.rocketChat
        ), forCellWithReuseIdentifier: ChatDirectMessageHeaderCell.identifier)

        autoCompletionView.register(UINib(
            nibName: "AutocompleteCell",
            bundle: Bundle.rocketChat
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
            self.buttonScrollToBottom.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: action)
        } else {
            action()
        }
    }

    // MARK: SlackTextViewController

    override public func canPressRightButton() -> Bool {
        return socketManager.isConnected()
    }

    override public func didPressRightButton(_ sender: Any?) {
        sendMessage()
    }

    override public func didPressLeftButton(_ sender: Any?) {
        buttonUploadDidPressed()
    }

    override public func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
        sendMessage()
    }

    override public func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom(true)
    }

    // MARK: Message

    fileprivate func sendMessage() {
        guard let messageText = textView.text, messageText.characters.count > 0 else { return }

        rightButton.isEnabled = false

        var message: Message?
        Realm.executeOnMainThread({ (realm) in
            message = Message()
            message?.internalType = ""
            message?.createdAt = Date.serverDate
            message?.text = messageText
            message?.subscription = self.subscription
            message?.identifier = String.random(18)
            message?.temporary = true
            message?.user = self.authManager.currentUser()

            if let message = message {
                realm.add(message)
            }
        })

        if let message = message {
            textView.text = ""
            rightButton.isEnabled = true

            subscriptionManager.sendTextMessage(message) { _ in
                Realm.executeOnMainThread({ (realm) in
                    message.temporary = false
                    realm.add(message, update: true)
                })
            }
        }
    }

    // MARK: Subscription

    fileprivate func markAsRead() {
        subscriptionManager.markAsRead(subscription) { _ in
            // Nothing, for now
        }
    }

    internal func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.stop()
        }

        title = subscription?.displayName()
        chatTitleView?.subscription = subscription
        textView.resignFirstResponder()

        collectionView?.performBatchUpdates({
            let indexPaths = self.dataController.clear()
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { _ in
            CATransaction.commit()
            self.activityIndicator.stopAnimating()
        })

        if self.subscription.isValid() {
            self.updateSubscriptionMessages()
        } else {
            self.subscription.fetchRoomIdentifier(subscriptionManager: subscriptionManager) { [weak self] response in
                self?.subscription = response
            }
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
        messagesQuery = subscription.fetchMessagesQueryResults()

        activityIndicator.startAnimating()

        dataController.loadedAllMessages = false
        isRequestingHistory = false
        loadMoreMessagesFrom(date: nil)
        updateMessagesQueryNotificationBlock()

        messageManager.changes(subscription)
    }

    fileprivate func updateMessagesQueryNotificationBlock() {
        messagesToken?.stop()
        messagesToken = messagesQuery.addNotificationBlock { [unowned self] changes in
            switch changes {
            case .initial: break
            case .update(_, _, let insertions, let modifications):
                if insertions.count > 0 {
                    var newMessages: [Message] = []
                    for insertion in insertions {
                        let newMessage = Message(value: self.messagesQuery[insertion])
                        newMessages.append(newMessage)
                    }

                    self.messages.append(contentsOf: newMessages)
                    self.appendMessages(messages: newMessages, completion: nil)
                    self.markAsRead()
                }

                if modifications.count == 0 {
                    return
                }

                let messagesCount = self.messagesQuery.count
                var indexPathModifications: [Int] = []

                for modified in modifications {
                    if messagesCount < modified + 1 {
                        continue
                    }

                    let message = Message(value: self.messagesQuery[modified])
                    let index = self.dataController.update(message)
                    if index >= 0 && !indexPathModifications.contains(index) {
                        indexPathModifications.append(index)
                    }
                }

                if indexPathModifications.count > 0 {
                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self.collectionView?.performBatchUpdates({
                                self.collectionView?.reloadItems(at: indexPathModifications.map { IndexPath(row: $0, section: 0) })
                            }, completion: nil)
                        }
                    }
                }

                break
            case .error: break
            }
        }
    }

    fileprivate func loadMoreMessagesFrom(date: Date?, loadRemoteHistory: Bool = true) {
        if isRequestingHistory || dataController.loadedAllMessages {
            return
        }

        isRequestingHistory = true

        func loadHistoryFromRemote() {
            let tempSubscription = Subscription(value: self.subscription)

            messageManager.getHistory(tempSubscription, lastMessageDate: date) { [weak self] messages in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    self?.isRequestingHistory = false

                    if messages.count == 0 {
                        self?.dataController.loadedAllMessages = true

                        self?.collectionView?.performBatchUpdates({
                            if let (indexPaths, removedIndexPaths) = self?.dataController.insert([]) {
                                self?.collectionView?.insertItems(at: indexPaths)
                                self?.collectionView?.deleteItems(at: removedIndexPaths)
                            }
                        }, completion: nil)
                    } else {
                        self?.dataController.loadedAllMessages = false
                    }
                }
            }
        }

        let newMessages = subscription.fetchMessages(lastMessageDate: date).map({ Message(value: $0) })
        if newMessages.count > 0 {
            messages.append(contentsOf: newMessages)
            appendMessages(messages: newMessages, completion: { [weak self] in
                self?.activityIndicator.stopAnimating()

                if date == nil {
                    self?.scrollToBottom()
                }

                if !loadRemoteHistory {
                    self?.isRequestingHistory = false
                } else {
                    loadHistoryFromRemote()
                }
            })
        } else {
            if loadRemoteHistory {
                loadHistoryFromRemote()
            } else {
                isRequestingHistory = false
            }
        }
    }

    fileprivate func appendMessages(messages: [Message], completion: VoidCompletion?) {
        guard let collectionView = self.collectionView else { return }

        var tempMessages: [Message] = []
        for message in messages {
            tempMessages.append(Message(value: message))
        }

        DispatchQueue.global(qos: .background).async {
            var objs: [ChatData] = []
            var newMessages: [Message] = []

            // Do not add duplicated messages
            for message in tempMessages {
                var insert = true

                for obj in self.dataController.data
                    where message.identifier == obj.message?.identifier {
                        insert = false
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
                DispatchQueue.main.async {
                    completion?()
                }

                return
            }

            DispatchQueue.main.async {
                collectionView.performBatchUpdates({
                    let (indexPaths, removedIndexPaths) = self.dataController.insert(objs)
                    collectionView.insertItems(at: indexPaths)
                    if self.messageCellStyle == .bubble {
                        collectionView.reloadItems(at: indexPaths
                            // Only items not the first
                            .filter { $0.row > 0 }
                            // Mapping into its previous one
                            .map { IndexPath(row: $0.row - 1, section: $0.section) }
                            // filter out items that just inserted
                            .filter { !indexPaths.contains($0) }
                        )
                    }
                    collectionView.deleteItems(at: removedIndexPaths)
                }, completion: { _ in
                    completion?()
                })
            }
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

    override public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < 4 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.data.count
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard dataController.data.count > indexPath.row else { return UICollectionViewCell() }
        guard let obj = dataController.itemAt(indexPath) else { return UICollectionViewCell() }

        if obj.type == .message {
            return cellForMessage(obj, at: indexPath)
        }

        if obj.type == .daySeparator {
            return cellForDaySeparator(obj, at: indexPath)
        }

        if obj.type == .loader {
            return cellForLoader(obj, at: indexPath)
        }

        if obj.type == .header {
            if subscription.type == .directMessage {
                return cellForDMHeader(obj, at: indexPath)
            } else {
                return cellForChannelHeader(obj, at: indexPath)
            }
        }

        return UICollectionViewCell()
    }

    // MARK: Cells

    func cellForMessage(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        switch messageCellStyle {
        case .normal:
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
        case .bubble:
            guard let message = obj.message else { return UICollectionViewCell() }
            if message.user == authManager.currentUser() {
                guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: ChatMessageBubbleCell.sentIdendifier, for: indexPath) as? ChatMessageBubbleCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.message = message
                cell.type = .sentBubble
                cell.dateLabel.isHidden = !dataController.shouldShowDate(atIndexPath: indexPath)
                return cell
            } else {
                guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: ChatMessageBubbleCell.receivedIdentifier, for: indexPath) as? ChatMessageBubbleCell else { return UICollectionViewCell() }
                cell.delegate = self
                cell.message = message
                cell.type = .receivedBubble
                cell.dateLabel.isHidden = !dataController.shouldShowDate(atIndexPath: indexPath)
                return cell
            }
        }
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

    func cellForChannelHeader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatChannelHeaderCell.identifier,
            for: indexPath
        ) as? ChatChannelHeaderCell else {
            return UICollectionViewCell()
        }
        cell.subscription = subscription
        return cell
    }

    func cellForDMHeader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatDirectMessageHeaderCell.identifier,
            for: indexPath
        ) as? ChatDirectMessageHeaderCell else {
            return UICollectionViewCell()
        }
        cell.subscription = subscription
        return cell
    }

    func cellForLoader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatLoaderCell.identifier,
            for: indexPath
        ) as? ChatLoaderCell else {
            return UICollectionViewCell()
        }

        return cell
    }

}

// MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout, MessageTextCacheManagerInjected {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch messageCellStyle {
        case .normal:
            return .zero
        case .bubble:
            return UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.bounds.size.width
        guard let obj = dataController.itemAt(indexPath) else {
            return CGSize(width: fullWidth, height: 40)
        }

        switch obj.type {
        case .header:
            if subscription.type == .directMessage {
                return CGSize(width: fullWidth, height: ChatDirectMessageHeaderCell.minimumHeight)
            } else {
                return CGSize(width: fullWidth, height: ChatChannelHeaderCell.minimumHeight)
            }
        case .loader:
            return CGSize(width: fullWidth, height: ChatLoaderCell.minimumHeight)
        case .daySeparator:
            return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
        default:
            guard let message = obj.message else {
                return CGSize(width: fullWidth, height: 40)
            }
            switch messageCellStyle {
            case .normal:
                let height = ChatMessageCell.cellMediaHeightFor(message: message, messageTextCacheManager: messageTextCacheManager)
                return CGSize(width: fullWidth, height: height)
            case .bubble:
                let style: MessageContainerStyle = message.user == authManager.currentUser() ? .sentBubble : .receivedBubble
                return ChatMessageBubbleCell.cellSizeFor(
                    fullWidth,
                    message: message,
                    style: style,
                    messageTextCacheManager: messageTextCacheManager
                )
            }
        }

    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch messageCellStyle {
        case .normal:
            return 10.0
        case .bubble:
            return 4
        }
    }
}

// MARK: UIScrollViewDelegate

extension ChatViewController {

    override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if scrollView.contentOffset.y < -10 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }
    }

    override public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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
        guard let auth = authManager.isAuthenticated() else { return }
        guard let subscription = self.subscription else { return }

        Realm.executeOnMainThread({ _ in
            subscription.auth = auth
        })

        self.subscription = subscription
    }

}
