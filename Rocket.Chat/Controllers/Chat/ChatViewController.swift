//
//  ChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SlackTextViewController
import SimpleImageViewer

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
    weak var chatHeaderViewStatus: ChatHeaderViewStatus?
    var documentController: UIDocumentInteractionController?

    var dataController = ChatDataController()

    var searchResult: [String: Any] = [:]

    var closeSidebarAfterSubscriptionUpdate = false

    var isRequestingHistory = false
    var isAppendingMessages = false

    let socketHandlerToken = String.random(5)
    var messagesToken: NotificationToken!
    var messagesQuery: Results<Message>!
    var messages: [Message] = []
    var subscription: Subscription! {
        didSet {
            updateSubscriptionInfo()
            markAsRead()
            typingIndicatorView?.dismissIndicator()

            if let oldValue = oldValue {
                unsubscribe(for: oldValue)
            }
        }
    }

    // MARK: View Life Cycle

    static var shared: ChatViewController? {
        if let main = UIApplication.shared.delegate?.window??.rootViewController as? MainChatViewController {
            if let nav = main.centerViewController as? UINavigationController {
                return nav.viewControllers.first as? ChatViewController
            }
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

        textInputbar.isTranslucent = false

        tableView?.separatorStyle = .none
        tableView?.allowsSelection = false

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

        NotificationCenter.default.addObserver(self, selector: #selector(reconnect), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        if !SocketManager.isConnected() {
            socketDidDisconnect(socket: SocketManager.sharedInstance)
        }

        guard let auth = AuthManager.isAuthenticated() else { return }
        let subscriptions = auth.subscriptions.sorted(byKeyPath: "lastSeen", ascending: false)
        if let subscription = subscriptions.first {
            self.subscription = subscription
        }

        view.bringSubview(toFront: activityIndicatorContainer)
        view.bringSubview(toFront: buttonScrollToBottom)
        view.bringSubview(toFront: textInputbar)
    }

    @objc internal func reconnect() {
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

        tableView?.contentInset = insets
        tableView?.scrollIndicatorInsets = insets
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
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

    fileprivate func registerCells() {
        tableView?.register(UINib(
            nibName: "LoaderTableViewCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: LoaderTableViewCell.identifier)

        tableView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChatMessageCell.identifier)

        tableView?.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChatMessageDaySeparator.identifier)

        tableView?.register(UINib(
            nibName: "ChatChannelHeaderCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChatChannelHeaderCell.identifier)

        tableView?.register(UINib(
            nibName: "ChatDirectMessageHeaderCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: ChatDirectMessageHeaderCell.identifier)

        autoCompletionView.register(UINib(
            nibName: "AutocompleteCell",
            bundle: Bundle.main
        ), forCellReuseIdentifier: AutocompleteCell.identifier)
    }

    fileprivate func scrollToBottom(_ animated: Bool = false) {
        guard let tableView = self.tableView else { return }
        let lastIndexPath = IndexPath(row: dataController.data.count - 1, section: 0)
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: animated)
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
        scrollToBottom(true)
    }

    override func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)
        } else {
            SubscriptionManager.sendTypingStatus(subscription, isTyping: true)
        }
    }

    // MARK: Message
    fileprivate func sendMessage() {
        guard let messageText = textView.text, messageText.characters.count > 0 else { return }

        self.scrollToBottom()
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
            message?.user = AuthManager.currentUser()

            if let message = message {
                realm.add(message)
            }
        })

        if let message = message {
            textView.text = ""
            rightButton.isEnabled = true
            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)

            SubscriptionManager.sendTextMessage(message) { response in
                Realm.executeOnMainThread({ (realm) in
                    message.temporary = false
                    message.map(response.result["result"], realm: realm)
                    realm.add(message, update: true)

                    MessageTextCacheManager.shared.update(for: message)
                })
            }
        }
    }

    fileprivate func chatLogIsAtBottom() -> Bool {
        guard let tableView = tableView else { return false }

        let height = tableView.bounds.height
        let bottomInset = tableView.contentInset.bottom
        let scrollContentSizeHeight = tableView.contentSize.height
        let verticalOffsetForBottom = scrollContentSizeHeight + bottomInset - height

        return tableView.contentOffset.y >= (verticalOffsetForBottom - 1)
    }

    // MARK: Subscription

    fileprivate func markAsRead() {
        SubscriptionManager.markAsRead(subscription) { _ in
            // Nothing, for now
        }
    }

    internal func unsubscribe(for subscription: Subscription) {
        SocketManager.unsubscribe(eventName: subscription.rid)
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/typing")
    }

    internal func updateSubscriptionInfo() {
        if let token = messagesToken {
            token.stop()
        }

        title = subscription?.displayName()
        chatTitleView?.subscription = subscription
        textView.resignFirstResponder()

        UIView.performWithoutAnimation {
            tableView?.beginUpdates()
            let indexPaths = self.dataController.clear()
            tableView?.deleteRows(at: indexPaths, with: .none)
            tableView?.endUpdates()
            tableView?.reloadData()
        }

        if self.closeSidebarAfterSubscriptionUpdate {
            MainChatViewController.closeSideMenuIfNeeded()
            self.closeSidebarAfterSubscriptionUpdate = false
        }

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
        messagesQuery = subscription.fetchMessagesQueryResults()

        activityIndicator.startAnimating()

        dataController.loadedAllMessages = false
        isRequestingHistory = false
        loadMoreMessagesFrom(date: nil)
        updateMessagesQueryNotificationBlock()

        MessageManager.changes(subscription)
        typingEvent()
    }

    fileprivate func typingEvent() {
        typingIndicatorView?.interval = 0

        SubscriptionManager.subscribeTypingEvent(subscription) { [weak self] username, flag in
            guard let username = username else { return }

            let isAtBottom = self?.chatLogIsAtBottom()

            if flag {
                self?.typingIndicatorView?.insertUsername(username)
            } else {
                self?.typingIndicatorView?.removeUsername(username)
            }

            if let isAtBottom = isAtBottom,
                isAtBottom == true {
                self?.scrollToBottom(true)
            }
        }
    }

    fileprivate func updateMessagesQueryNotificationBlock() {
        messagesToken?.stop()
        messagesToken = messagesQuery.addNotificationBlock { [unowned self] changes in
            switch changes {
            case .initial: break
            case .update(_, _, let insertions, let modifications):
                if insertions.count > 0 {
                    if insertions.count > 1 && self.isRequestingHistory {
                        return
                    }

                    var newMessages: [Message] = []
                    for insertion in insertions {
                        let newMessage = Message(value: self.messagesQuery[insertion])
                        newMessages.append(newMessage)
                    }

                    self.messages.append(contentsOf: newMessages)
                    self.appendMessages(messages: newMessages, completion: {
                        self.markAsRead()
                    })
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
                    let isAtBottom = self.chatLogIsAtBottom()

                    DispatchQueue.main.async {
                        UIView.performWithoutAnimation {
                            self.tableView?.beginUpdates()
                            self.tableView?.reloadRows(at: indexPathModifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                            self.tableView?.endUpdates()

                            if isAtBottom {
                                self.scrollToBottom()
                            }
                        }
                    }
                }

                break
            case .error: break
            }
        }
    }

    fileprivate func loadMoreMessagesFrom(date: Date?, loadRemoteHistory: Bool = true) {
        guard let tableView = self.tableView else { return }

        if isRequestingHistory || dataController.loadedAllMessages {
            return
        }

        isRequestingHistory = true

        func loadHistoryFromRemote() {
            let tempSubscription = Subscription(value: self.subscription)

            MessageManager.getHistory(tempSubscription, lastMessageDate: date) { messages in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.isRequestingHistory = false
                    self.loadMoreMessagesFrom(date: date, loadRemoteHistory: false)

                    if messages.count == 0 {
                        self.dataController.loadedAllMessages = true

                        let oldHeight = tableView.contentSize.height
                        UIView.performWithoutAnimation {
                            tableView.beginUpdates()
                            let (indexPaths, removedIndexPaths) = self.dataController.insert([])
                            tableView.insertRows(at: indexPaths, with: .none)
                            tableView.deleteRows(at: removedIndexPaths, with: .none)
                            tableView.endUpdates()
                            tableView.reloadData()
                        }

                        let newHeight = tableView.contentSize.height
                        tableView.contentOffset = CGPoint(x: 0, y: newHeight - oldHeight)
                    } else {
                        self.dataController.loadedAllMessages = false
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

                if SocketManager.isConnected() {
                    if !loadRemoteHistory {
                        self?.isRequestingHistory = false
                    } else {
                        loadHistoryFromRemote()
                    }
                } else {
                    self?.isRequestingHistory = false
                }
            })
        } else {
            if SocketManager.isConnected() {
                if loadRemoteHistory {
                    loadHistoryFromRemote()
                } else {
                    isRequestingHistory = false
                }
            } else {
                isRequestingHistory = false
            }
        }
    }

    fileprivate func appendMessages(messages: [Message], completion: VoidCompletion?) {
        guard !isAppendingMessages else { return }
        guard let tableView = self.tableView else { return }

        isAppendingMessages = true

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
                var obj = ChatData(type: .message, timestamp: createdAt)
                obj.message = message
                objs.append(obj)
            }

            // No new data? Don't update it then
            if objs.count == 0 {
                DispatchQueue.main.async {
                    self.isAppendingMessages = false
                    completion?()
                }

                return
            }

            DispatchQueue.main.async {
                let isAtBottom = self.chatLogIsAtBottom()
                let oldHeight = tableView.contentSize.height

                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    let (indexPaths, removedIndexPaths) = self.dataController.insert(objs)
                    tableView.insertRows(at: indexPaths, with: .none)
                    tableView.deleteRows(at: removedIndexPaths, with: .none)
                    tableView.endUpdates()
                    tableView.reloadData()
                    self.isAppendingMessages = false
                    completion?()
                }

                if isAtBottom {
                    self.scrollToBottom()
                } else {
                    let newHeight = tableView.contentSize.height
                    let newY = tableView.contentOffset.y
                    tableView.contentOffset = CGPoint(x: 0, y: newY + newHeight - oldHeight)
                }
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

    // MARK: IBAction

    @objc func chatTitleViewDidPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "Channel Info", sender: sender)
    }

    @IBAction func buttonScrollToBottomPressed(_ sender: UIButton) {
        scrollToBottom(true)
    }
}

// MARK: UITableViewDataSource

extension ChatViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.autoCompletionView {
            return autoCompletionCellForRowAtIndexPath(indexPath)
        }

        if tableView == self.tableView {
            return cellForChatDataAtIndexPath(indexPath)
        }

        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.autoCompletionView {
            return heightForAutoCompletionCell()
        }

        if tableView == self.tableView {
            return heightForChatDataAtIndexPath(indexPath)
        }

        return 40
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == autoCompletionView {
            return autoCompletionNumberOfRowsInSection(section)
        } else if tableView == self.tableView {
            return dataController.data.count
        }

        return 0
    }
}

// MARK: UITableViewDelegate

extension ChatViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.autoCompletionView {
            autoCompletionDidSelectRowAt(indexPath: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row < 4 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }
    }
}

// MARK: Cells

extension ChatViewController {
    func heightForChatDataAtIndexPath(_ indexPath: IndexPath) -> CGFloat {
        if let obj = dataController.itemAt(indexPath) {
            if obj.type == .header {
                if subscription.type == .directMessage {
                    return ChatDirectMessageHeaderCell.minimumHeight
                } else {
                    return ChatChannelHeaderCell.minimumHeight
                }
            }

            if obj.type == .loader {
                return LoaderTableViewCell.minimumHeight
            }

            if obj.type == .daySeparator {
                return ChatMessageDaySeparator.minimumHeight
            }

            if let message = obj.message {
                let sequential = dataController.hasSequentialMessageAt(indexPath)
                let height = ChatMessageCell.cellMediaHeightFor(message: message, sequential: sequential)
                return height
            }
        }

        return 40
    }

    func cellForChatDataAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        guard dataController.data.count > indexPath.row else { return UITableViewCell() }
        guard let obj = dataController.itemAt(indexPath) else { return UITableViewCell() }

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

        return UITableViewCell()
    }

    func cellForMessage(_ obj: ChatData, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(
            withIdentifier: ChatMessageCell.identifier,
            for: indexPath
        ) as? ChatMessageCell else {
            return UITableViewCell()
        }

        cell.delegate = self

        if let message = obj.message {
            cell.message = message
        }

        cell.sequential = dataController.hasSequentialMessageAt(indexPath)

        return cell
    }

    func cellForDaySeparator(_ obj: ChatData, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(
            withIdentifier: ChatMessageDaySeparator.identifier,
            for: indexPath
        ) as? ChatMessageDaySeparator else {
                return UITableViewCell()
        }
        cell.labelTitle.text = obj.timestamp.formatted("MMM dd, YYYY")
        return cell
    }

    func cellForChannelHeader(_ obj: ChatData, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(
            withIdentifier: ChatChannelHeaderCell.identifier,
            for: indexPath
        ) as? ChatChannelHeaderCell else {
            return UITableViewCell()
        }
        cell.subscription = subscription
        return cell
    }

    func cellForDMHeader(_ obj: ChatData, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(
            withIdentifier: ChatDirectMessageHeaderCell.identifier,
            for: indexPath
        ) as? ChatDirectMessageHeaderCell else {
            return UITableViewCell()
        }
        cell.subscription = subscription
        return cell
    }

    func cellForLoader(_ obj: ChatData, at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView?.dequeueReusableCell(
            withIdentifier: LoaderTableViewCell.identifier,
            for: indexPath
        ) as? LoaderTableViewCell else {
            return UITableViewCell()
        }

        return cell
    }
}

// MARK: UIScrollViewDelegate

extension ChatViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if scrollView.contentOffset.y < -10 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }
    }

    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let view = buttonScrollToBottom.superview else { return }

        if buttonScrollToBottomMarginConstraint == nil {
            buttonScrollToBottomMarginConstraint = buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
            buttonScrollToBottomMarginConstraint?.isActive = true
        }

        if targetContentOffset.pointee.y.rounded() < scrollView.contentSize.height - scrollView.frame.height {
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
