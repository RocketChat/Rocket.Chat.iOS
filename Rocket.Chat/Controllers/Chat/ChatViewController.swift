//
//  ChatViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/21/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SlackTextViewController

private typealias NibCellIndentifier = (nibName: String, cellIdentifier: String)
private let kEmptyCellIdentifier = "kEmptyCellIdentifier"

private let buttonScrollToBottomSize = CGFloat(70)

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

    lazy var uploadClient = API.current()?.client(UploadClient.self)
    lazy var bannerView: ChatBannerView? = setupBanner()

    lazy var buttonScrollToBottom: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: .greatestFiniteMagnitude, y: .greatestFiniteMagnitude, width: buttonScrollToBottomSize, height: buttonScrollToBottomSize)
        button.setImage(UIImage(named: "Float Button light"), for: .normal)
        button.addTarget(self, action: #selector(buttonScrollToBottomDidPressed), for: .touchUpInside)
        return button
    }()

    var scrollToBottomButtonIsVisible: Bool = false {
        didSet {
            guard oldValue != scrollToBottomButtonIsVisible,
                let collectionView = collectionView
            else {
                scrollToBottomButtonIsVisible = !scrollToBottomButtonIsVisible
                return
            }

            func animates(_ animations: @escaping VoidCompletion) {
                UIView.animate(withDuration: 0.15, delay: 0, options: UIView.AnimationOptions(rawValue: 7 << 16), animations: {
                    animations()
                }, completion: nil)
            }

            if self.scrollToBottomButtonIsVisible {
                if buttonScrollToBottom.superview == nil {
                    view.addSubview(buttonScrollToBottom)
                }

                var frame = buttonScrollToBottom.frame
                frame.origin.x = collectionView.frame.width - buttonScrollToBottomSize - view.layoutMargins.right
                frame.origin.y = collectionView.frame.origin.y + collectionView.frame.height - buttonScrollToBottomSize - collectionView.layoutMargins.bottom

                animates({
                    self.buttonScrollToBottom.frame = frame
                    self.buttonScrollToBottom.alpha = 1
                })
            } else {
                var frame = buttonScrollToBottom.frame
                frame.origin.x = collectionView.frame.width - buttonScrollToBottomSize - view.layoutMargins.right
                frame.origin.y = collectionView.frame.origin.y + collectionView.frame.height

                animates({
                    self.buttonScrollToBottom.frame = frame
                    self.buttonScrollToBottom.alpha = 0
                })
            }
        }
    }

    weak var chatTitleView: ChatTitleView?
    weak var chatPreviewModeView: ChatPreviewModeView?
    var documentController: UIDocumentInteractionController?

    var replyView: ReplyView!
    var replyString: String = ""
    var messageToEdit: Message?
    var lastTimeSentTypingEvent: Date?

    var dataController = ChatDataController()

    var searchResult: [(String, Any)] = []
    var searchWord: String = ""

    var isRequestingHistory = false
    var isAppendingMessages = false

    var subscriptionToken: NotificationToken?

    var messagesToken: NotificationToken!
    var messagesQuery: Results<Message>!
    var messages: [Message] = []

    var backgroundImageViewEmptyState: UIImageView?

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else {
                return
            }

            resetUnreadSeparator()

            subscription.setTemporaryMessagesFailed()

            subscriptionToken = subscription.observe { [weak self] changes in
                switch changes {
                case .change(let propertyChanges):
                    self?.chatTitleView?.subscription = self?.subscription

                    propertyChanges.forEach {
                        if $0.name == "roomReadOnly" || $0.name == "roomMuted" {
                            self?.updateMessageSendingPermission()
                        }
                    }
                default:
                    break
                }
            }

            emptySubscriptionState()
            updateSubscriptionInfo()
            markAsRead()
            typingIndicatorView?.dismissIndicator()
            textView.text = DraftMessageManager.draftMessage(for: subscription)
        }
    }

    let socketHandlerToken = String.random(5)

    // MARK: View Life Cycle

    deinit {
        NotificationCenter.default.removeObserver(self)
        SocketManager.removeConnectionHandler(token: socketHandlerToken)
        messagesToken?.invalidate()
        subscriptionToken?.invalidate()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        registerCells()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        SocketManager.addConnectionHandler(token: socketHandlerToken, handler: self)

        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        }

        collectionView?.isPrefetchingEnabled = true
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.showsHorizontalScrollIndicator = false
        enableInteractiveKeyboardDismissal()

        isInverted = false
        bounces = true
        shakeToClearEnabled = true
        isKeyboardPanningEnabled = true
        shouldScrollToBottomAfterKeyboardShows = false

        leftButton.setImage(UIImage(named: "Upload"), for: .normal)

        setupTitleView()
        setupTextViewSettings()

        // Remove title from back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        view.bringSubviewToFront(activityIndicatorContainer)
        view.bringSubviewToFront(buttonScrollToBottom)
        view.bringSubviewToFront(textInputbar)

        setupReplyView()
        ThemeManager.addObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        keyboardFrame?.updateFrame()
        ThemeManager.addObserver(navigationController?.navigationBar)
        setupAutoCompletionSeparator()
        textInputbar.applyTheme()

        textInputbar.textView.inputAssistantItem.leadingBarButtonGroups = []
        textInputbar.textView.inputAssistantItem.trailingBarButtonGroups = []

        updateEmptyState()

        chatTitleView?.state = SocketManager.sharedInstance.state

        if let subscription = subscription {
            subscribe(for: subscription)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let screenName = String(describing: ChatViewController.self)
        AnalyticsManager.log(event: .screenView(screenName: screenName))

        dataController.invalidateLayout(for: nil)
        collectionView?.setNeedsLayout()
        collectionView?.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)

        if let subscription = subscription?.validated() {
            unsubscribe(for: subscription)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateChatPreviewModeViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEmptyBackgroundImageFrames()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let visibleIndexPaths = collectionView?.indexPathsForVisibleItems ?? []
        let topIndexPath = visibleIndexPaths.sorted().first

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.dataController.invalidateLayout(for: nil)

            self?.collectionView?.reloadData()
            self?.tableView?.reloadData()
        }, completion: { [weak self] _ in
            if let indexPath = topIndexPath {
                self?.collectionView?.scrollToItem(at: indexPath, at: .top, animated: false)
            }
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Channel Actions", let nav = segue.destination as? UINavigationController {
            if let controller = nav.viewControllers.first as? ChannelActionsViewController {
                if let subscription = self.subscription {
                    controller.subscription = subscription
                }
            }
        }
    }

    private func setupTextViewSettings() {
        textView.registerMarkdownFormattingSymbol("*", withTitle: "Bold")
        textView.registerMarkdownFormattingSymbol("_", withTitle: "Italic")
        textView.registerMarkdownFormattingSymbol("~", withTitle: "Strike")
        textView.registerMarkdownFormattingSymbol("`", withTitle: "Code")
        textView.registerMarkdownFormattingSymbol("```", withTitle: "Preformatted")
        textView.registerMarkdownFormattingSymbol(">", withTitle: "Quote")

        registerPrefixes(forAutoCompletion: ["@", "#", "/", ":"])
    }

    private func setupTitleView() {
        let view = ChatTitleView.instantiateFromNib()
        view?.subscription = subscription
        view?.delegate = self
        navigationItem.titleView = view
        chatTitleView = view
        chatTitleView?.applyTheme()
    }

    private func setupAutoCompletionSeparator() {
        guard let hairlineView = self.value(forKey: "autoCompletionHairline") as? UIView else { return }
        hairlineView.setThemeColor("backgroundColor: mutedAccent")
        hairlineView.applyTheme()
    }

    override class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
        return ChatCollectionViewFlowLayout()
    }

    private func registerCells() {
        let collectionViewCells: [NibCellIndentifier] = [
            (nibName: "ChatLoaderCell", cellIdentifier: ChatLoaderCell.identifier),
            (nibName: "ChatMessageCell", cellIdentifier: ChatMessageCell.identifier),
            (nibName: "ChatMessageDaySeparator", cellIdentifier: ChatMessageDaySeparator.identifier),
            (nibName: "ChatMessageUnreadSeparator", cellIdentifier: ChatMessageUnreadSeparator.identifier),
            (nibName: "ChatChannelHeaderCell", cellIdentifier: ChatChannelHeaderCell.identifier),
            (nibName: "ChatDirectMessageHeaderCell", cellIdentifier: ChatDirectMessageHeaderCell.identifier)
        ]

        // This cell is used in case no other cell is available or useful.
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kEmptyCellIdentifier)

        collectionViewCells.forEach {
            collectionView?.register(UINib(
                nibName: $0.nibName,
                bundle: Bundle.main
            ), forCellWithReuseIdentifier: $0.cellIdentifier)
        }

        let autoCompletionViewCells: [NibCellIndentifier] = [
            (nibName: "AutocompleteCell", cellIdentifier: AutocompleteCell.identifier),
            (nibName: "EmojiAutocompleteCell", cellIdentifier: EmojiAutocompleteCell.identifier)
        ]

        autoCompletionViewCells.forEach {
            autoCompletionView.register(UINib(
                nibName: $0.nibName,
                bundle: Bundle.main
            ), forCellReuseIdentifier: $0.cellIdentifier)
        }
    }

    @objc internal func scrollToBottom(_ animated: Bool = false) {
        let boundsHeight = collectionView?.bounds.size.height ?? 0
        let sizeHeight = collectionView?.contentSize.height ?? 0
        let offset = CGPoint(x: 0, y: max(sizeHeight - boundsHeight, 0))
        collectionView?.setContentOffset(offset, animated: animated)
        scrollToBottomButtonIsVisible = false
    }

    @objc internal func buttonScrollToBottomDidPressed() {
        scrollToBottom(true)
    }

    internal func resetScrollToBottomButtonPosition() {
        scrollToBottomButtonIsVisible = !chatLogIsAtBottom()
    }

    func resetMessageSending() {
        textView.text = ""

        if let subscription = subscription {
            DraftMessageManager.update(draftMessage: "", for: subscription)
            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)
        }
    }

    func resetUnreadSeparator() {
        dataController.dismissUnreadSeparator = true
        dataController.lastSeen = Date()
    }

    // MARK: Handling Keyboard

    // keyboardHeightConstraint is the same as keyboardHC in SLKTextViewController
    weak var keyboardHeightConstraint: NSLayoutConstraint?
    weak var textInputbarBackgroundHeightConstraint: NSLayoutConstraint?

    var keyboardFrame: KeyboardFrameView?
    let textInputbarBackground = UIToolbar()
    var oldTextInputbarBgIsTransparent = false

    private func enableInteractiveKeyboardDismissal() {
        keyboardFrame = KeyboardFrameView(withDelegate: self)
    }

    // Enables for the interactive keyboard dismissal.
    // Gets called updateKeyboardConstraints(frame:) which is a
    // required method of the KeyboardFrameViewDelegate
    private func updateKeyboardConstraints(frame: CGRect) {
        if keyboardHeightConstraint == nil {
            keyboardHeightConstraint = self.view.constraints.first {
                ($0.firstItem as? UIView) == self.view &&
                    ($0.secondItem as? SLKTextInputbar) == self.textInputbar
            }
        }

        // Adding textInputBar background so that the app can support devices with safe area insets.
        // The tool bar (textInputBar) background sometimes dissapears on keyboard slide outs,
        // with no real fix for it provided by Apple in UIKit.
        updateTextInputbarBackground()

        var keyboardHeight = frame.height

        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardHeight > view.safeAreaInsets.bottom ? keyboardHeight : view.safeAreaInsets.bottom
        }

        keyboardHeightConstraint?.constant = keyboardHeight
    }

    private func updateTextInputbarBackground() {
        if #available(iOS 11.0, *) {
            if !textInputbar.subviews.contains(textInputbarBackground) {
                insertTextInputbarBackground()
            }
        }
    }

    private func insertTextInputbarBackground() {
        textInputbar.insertSubview(textInputbarBackground, at: 0)
        textInputbarBackground.translatesAutoresizingMaskIntoConstraints = false

        textInputbarBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        textInputbarBackground.widthAnchor.constraint(equalTo: textInputbar.widthAnchor).isActive = true
        textInputbarBackground.topAnchor.constraint(equalTo: textInputbar.topAnchor).isActive = true
        textInputbarBackground.centerXAnchor.constraint(equalTo: textInputbar.centerXAnchor).isActive = true
    }

    // MARK: SlackTextViewController

    override func didPressRightButton(_ sender: Any?) {
        guard let messageText = textView.text else { return }

        resetMessageSending()
        scrollToBottom()

        let replyString = self.replyString
        stopReplying()

        dataController.dismissUnreadSeparator = true
        dataController.lastSeen = Date()

        let text = "\(messageText)\(replyString)"

        if let (command, params) = text.commandAndParams() {
            sendCommand(command: command, params: params)
            return
        }

        sendTextMessage(text: text)
    }

    override func didCommitTextEditing(_ sender: Any) {
        if let messageToEdit = messageToEdit {
            editTextMessage(message: messageToEdit, text: textView.text)
        }

        resetMessageSending()
        messageToEdit = nil

        super.didCommitTextEditing(sender)
    }

    override func didCancelTextEditing(_ sender: Any) {
        messageToEdit = nil
        super.didCancelTextEditing(sender)
    }

    override func didPressLeftButton(_ sender: Any?) {
        buttonUploadDidPressed()
    }

    override func didPressReturnKey(_ keyCommand: UIKeyCommand?) {
        if messageToEdit != nil {
            didCommitTextEditing(self)
        } else {
            didPressRightButton(self)
        }
    }

    override func textViewDidChange(_ textView: UITextView) {
        guard let subscription = self.subscription else { return }

        // Intervals
        let kDefaultTypingInterval = 3 // seconds
        let kDefaultTypingIntervalCheck = 5 // seconds

        // Update draft text
        DraftMessageManager.update(draftMessage: textView.text, for: subscription)

        if textView.text?.isEmpty ?? true {
            SubscriptionManager.sendTypingStatus(subscription, isTyping: false)
        } else {
            // We're not calling this event every char because the web starts flickering
            // the "typing" view.
            if let lastTimeSentTypingEvent = lastTimeSentTypingEvent {
                if Int(Date().timeIntervalSince(lastTimeSentTypingEvent)) < kDefaultTypingInterval {
                    return
                }
            }

            // User is typing right now
            lastTimeSentTypingEvent = Date()
            SubscriptionManager.sendTypingStatus(subscription, isTyping: true)

            // After 5 seconds without writing, we send an event
            // telling the server that user is not typing anymore
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(kDefaultTypingIntervalCheck)) { [weak self] in
                if let lastTimeSentTypingEvent = self?.lastTimeSentTypingEvent {
                    if Int(Date().timeIntervalSince(lastTimeSentTypingEvent)) >= kDefaultTypingIntervalCheck {
                        SubscriptionManager.sendTypingStatus(subscription, isTyping: false)
                    }
                }
            }
        }
    }

    @objc override func keyboardWillShow(_ notification: Notification) {
        // Scroll to the bottom when the collectionView has scrolled more
        // than scrollToBottomHeightMultiplier times the view's height.
        let scrollToBottomHeightMultiplier: CGFloat = 1.2

        let contentHeight = collectionView?.contentSize.height ?? 0
        let contentOffset = collectionView?.contentOffset.y ?? 0
        if contentHeight - contentOffset < self.view.frame.height * scrollToBottomHeightMultiplier {
            scrollToBottom()
        }
    }

    // MARK: Message
    func sendCommand(command: String, params: String) {
        guard let subscription = subscription else { return }

        let client = API.current()?.client(CommandsClient.self)
        client?.runCommand(command: command, params: params, roomId: subscription.rid, errored: alertAPIError)
    }

    private func sendTextMessage(text: String) {
        guard
            let subscription = subscription,
            text.count > 0
        else {
            return
        }

        guard let client = API.current()?.client(MessagesClient.self) else { return Alert.defaultError.present() }
        client.sendMessage(text: text, subscription: subscription)
    }

    private func editTextMessage(message: Message, text: String) {
        guard let client = API.current()?.client(MessagesClient.self) else { return Alert.defaultError.present() }
        client.updateMessage(message, text: text)
    }

    private func updateCellForMessage(identifier: String) {
        guard let indexPath = self.dataController.indexPathOfMessage(identifier: identifier) else { return }

        UIView.performWithoutAnimation {
            collectionView?.reloadItems(at: [indexPath])
        }
    }

    private func chatLogIsAtBottom() -> Bool {
        guard let collectionView = collectionView else { return false }

        let height = collectionView.bounds.height
        let bottomInset = collectionView.contentInset.bottom
        let scrollContentSizeHeight = collectionView.contentSize.height
        let verticalOffsetForBottom = scrollContentSizeHeight + bottomInset - height

        return collectionView.contentOffset.y >= (verticalOffsetForBottom - buttonScrollToBottomSize)
    }

    // MARK: Subscription

    private func markAsRead() {
        guard let subscription = subscription else { return }

        API.current()?.client(SubscriptionsClient.self).markAsRead(subscription: subscription)
    }

    internal func subscribe(for subscription: Subscription) {
        MessageManager.changes(subscription)
        MessageManager.subscribeDeleteMessage(subscription) { [weak self] msgId in
            DispatchQueue.main.async { [weak self] in
                self?.deleteMessage(msgId: msgId)
            }
        }
        registerTypingEvent(subscription)
    }

    internal func unsubscribe(for subscription: Subscription) {
        SocketManager.unsubscribe(eventName: subscription.rid)
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/typing")
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/deleteMessage")
    }

    internal func updateEmptyState() {
        if self.subscription == nil {
            title = ""
            setTextInputbarHidden(true, animated: false)

            chatTitleView?.removeFromSuperview()
            backgroundImageViewEmptyState?.removeFromSuperview()

            guard let theme = view.theme else { return }
            let themeName = ThemeManager.themes.first { $0.theme == theme }?.title

            let backgroundImageView = UIImageView(image: UIImage(named: "Empty State \(themeName ?? "light")"))
            backgroundImageView.contentMode = .scaleAspectFill
            backgroundImageView.clipsToBounds = true
            self.view.insertSubview(backgroundImageView, belowSubview: textInputbar)

            backgroundImageViewEmptyState = backgroundImageView
            updateEmptyBackgroundImageFrames()
        } else {
            backgroundImageViewEmptyState?.removeFromSuperview()
            updateJoinedView()
        }
    }

    internal func emptySubscriptionState() {
        dataController.invalidateLayout(for: nil)
        clearListData()
        updateJoinedView()

        activityIndicator?.startAnimating()
        textView.resignFirstResponder()
    }

    internal func updateJoinedView() {
        guard let subscription = subscription else { return }

        if subscription.isJoined() {
            setTextInputbarHidden(false, animated: false)
            chatPreviewModeView?.removeFromSuperview()
        } else {
            setTextInputbarHidden(true, animated: false)
            showChatPreviewModeView()
        }
    }

    internal func clearListData() {
        collectionView?.performBatchUpdates({
            let indexPaths = self.dataController.clear()
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { _ in
            CATransaction.commit()
        })
    }

    internal func deleteMessage(msgId: String) {
        guard let collectionView = collectionView else { return }
        dataController.delete(msgId: msgId)
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        })
        Realm.execute({ _ in
            Message.delete(withIdentifier: msgId)
        })
    }

    internal func updateSubscriptionInfo() {
        guard let subscription = subscription else { return }

        messagesToken?.invalidate()

        title = subscription.displayName()
        chatTitleView?.subscription = subscription

        if subscription.isValid() {
            updateSubscriptionMessages()
        } else {
            subscription.fetchRoomIdentifier({ [weak self] response in
                self?.subscription = response
            })
        }

        updateSubscriptionRoles()
        updateMessageSendingPermission()
    }

    internal func updateSubscriptionMessages() {
        guard let subscription = subscription else { return }

        messagesQuery = subscription.fetchMessagesQueryResults()

        dataController.loadedAllMessages = false
        isRequestingHistory = false

        updateMessagesQueryNotificationBlock()
        loadMoreMessagesFrom(date: nil)
        subscribe(for: subscription)
    }

    func registerTypingEvent(_ subscription: Subscription) {
        typingIndicatorView?.interval = 0
        guard let user = AuthManager.currentUser() else { return Log.debug("Could not register TypingEvent") }

        let loggedUsername = user.username
        SubscriptionManager.subscribeTypingEvent(subscription) { [weak self] username, flag in
            guard let username = username, username != loggedUsername else { return }

            DispatchQueue.main.async {
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
    }

    private func updateMessagesQueryNotificationBlock() {
        messagesToken?.invalidate()
        messagesToken = messagesQuery.observe { [unowned self] changes in
            guard case .update(_, _, let insertions, let modifications) = changes else {
                return
            }

            if insertions.count > 0 {
                var newMessages: [Message] = []
                for insertion in insertions {
                    guard insertion < self.messagesQuery.count else { continue }
                    let newMessage = Message(value: self.messagesQuery[insertion])
                    newMessages.append(newMessage)
                }

                self.messages.append(contentsOf: newMessages)

                self.appendMessages(messages: newMessages, completion: {
                    self.markAsRead()
                })
            }

            if modifications.count > 0 {
                let isAtBottom = self.chatLogIsAtBottom()

                var indexPathModifications: [Int] = []

                for modified in modifications {
                    guard modified < self.messagesQuery.count else { continue }

                    let message = Message(value: self.messagesQuery[modified])
                    let index = self.dataController.update(message)

                    if index >= 0 && !indexPathModifications.contains(index) {
                        indexPathModifications.append(index)
                    }
                }

                if indexPathModifications.count > 0 {
                    UIView.performWithoutAnimation { [weak self] in
                        self?.collectionView?.performBatchUpdates({
                            self?.collectionView?.reloadItems(at: indexPathModifications.map { IndexPath(row: $0, section: 0) })
                        }, completion: { [weak self] _ in
                            if isAtBottom {
                                self?.scrollToBottom()
                            }
                        })
                    }
                }
            }
        }
    }

    func syncCollectionView() {
        collectionView?.performBatchUpdates({
            let (indexPaths, removedIndexPaths) = dataController.insert([])
            collectionView?.insertItems(at: indexPaths)
            collectionView?.deleteItems(at: removedIndexPaths)
        }, completion: nil)
    }

    func loadHistoryFromRemote(date: Date?, loadNextPage: Bool = true) {
        guard let subscription = subscription?.validated() else { return }

        let tempSubscription = Subscription(value: subscription)

        MessageManager.getHistory(tempSubscription, lastMessageDate: date) { [weak self] nextPageDate in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()

                if loadNextPage {
                    self?.isRequestingHistory = false
                    self?.loadMoreMessagesFrom(date: date, loadRemoteHistory: false)
                }

                if nextPageDate == nil {
                    self?.dataController.loadedAllMessages = true
                    self?.syncCollectionView()
                } else {
                    self?.dataController.loadedAllMessages = false
                }

                if let nextPageDate = nextPageDate, loadNextPage {
                    self?.loadHistoryFromRemote(date: nextPageDate, loadNextPage: false)
                }
            }
        }
    }

    private func loadMoreMessagesFrom(date: Date?, loadRemoteHistory: Bool = true) {
        guard let subscription = subscription else { return }

        isRequestingHistory = true

        let newMessages = subscription.fetchMessages(lastMessageDate: date).map({ Message(value: $0) })
        if newMessages.count > 0 {
            messages.append(contentsOf: newMessages)
            appendMessages(messages: newMessages, completion: { [weak self] in
                self?.activityIndicator.stopAnimating()

                if date == nil {
                    self?.collectionView?.reloadData()
                }

                if SocketManager.isConnected() {
                    if !loadRemoteHistory {
                        self?.isRequestingHistory = false
                    } else {
                        self?.loadHistoryFromRemote(date: date)
                    }
                } else {
                    self?.isRequestingHistory = false
                }
            })
        } else {
            if date == nil {
                collectionView?.reloadData()
            }

            if SocketManager.isConnected() {
                if loadRemoteHistory {
                    loadHistoryFromRemote(date: date)
                } else {
                    isRequestingHistory = false
                }
            } else {
                isRequestingHistory = false
            }
        }
    }

    private func appendMessages(messages: [Message], completion: VoidCompletion?) {
        guard let subscription = subscription?.validated(), let collectionView = collectionView else {
            return
        }

        guard !isAppendingMessages else {
            Log.debug("[APPEND MESSAGES] Blocked trying to append \(messages.count) messages")
            // This message can be called many times during the app execution and we need
            // to call them one per time, to avoid adding the same message multiple times
            // to the list. Also, we keep the subscription identifier in order to make sure
            // we're updating the same subscription, because this view controller is reused
            // for all the chats.

            let oldSubscriptionIdentifier = subscription.identifier
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                guard
                    self?.subscription?.validated() != nil,
                    oldSubscriptionIdentifier == self?.subscription?.identifier
                else {
                    return
                }

                self?.appendMessages(messages: messages, completion: completion)
            })

            return
        }

        isAppendingMessages = true

        let tempMessages = messages.map { Message(value: $0) }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            let chatData = self.insertMessages(messages: tempMessages)

            // No new data? Don't update it then
            if chatData.count == 0 {
                if self.dataController.dismissUnreadSeparator {
                    DispatchQueue.main.async {
                        self.syncCollectionView()
                    }
                }

                DispatchQueue.main.async {
                    self.isAppendingMessages = false
                    completion?()
                }

                return
            }

            DispatchQueue.main.async {
                collectionView.performBatchUpdates({
                    let (indexPaths, removedIndexPaths) = self.dataController.insert(chatData)
                    collectionView.insertItems(at: indexPaths)
                    collectionView.deleteItems(at: removedIndexPaths)
                }, completion: { _ in
                    self.isAppendingMessages = false
                    completion?()
                })
            }
        }
    }

    private func insertMessages(messages: [Message]) -> [ChatData] {
        var objs: [ChatData] = []
        var newMessages: [Message] = []

        // Do not add duplicated messages
        for message in messages {
            var insert = true

            for obj in self.dataController.data where message.identifier == obj.message?.identifier {
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

        return objs
    }

    private func showChatPreviewModeView() {
        chatPreviewModeView?.removeFromSuperview()

        if let previewView = ChatPreviewModeView.instantiateFromNib() {
            previewView.delegate = self
            previewView.subscription = subscription
            previewView.translatesAutoresizingMaskIntoConstraints = false

            view.addSubview(previewView)

            NSLayoutConstraint.activate([
                previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            collectionView?.bottomAnchor.constraint(equalTo: previewView.topAnchor).isActive = true

            chatPreviewModeView = previewView
            updateChatPreviewModeViewConstraints()

            previewView.applyTheme()
        }
    }

    private func updateEmptyBackgroundImageFrames() {
        guard let backgroundImageViewEmptyState = backgroundImageViewEmptyState else { return }
        backgroundImageViewEmptyState.frame = view.bounds
    }

    private func updateChatPreviewModeViewConstraints() {
        if #available(iOS 11.0, *) {
            chatPreviewModeView?.bottomInset = view.safeAreaInsets.bottom
        }
    }

    private func isContentBiggerThanContainerHeight() -> Bool {
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

    @IBAction func showSearchMessages() {
        guard
            let storyboard = storyboard,
            let messageList = storyboard.instantiateViewController(withIdentifier: "MessagesList") as? MessagesListViewController
            else {
                return
        }

        messageList.data.subscription = subscription
        messageList.data.isSearchingMessages = true
        let searchMessagesNav = BaseNavigationController(rootViewController: messageList)

        present(searchMessagesNav, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource

extension ChatViewController {

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row < 4 {
            if let message = dataController.oldestMessage() {
                loadMoreMessagesFrom(date: message.createdAt)
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataController.data.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            dataController.data.count > indexPath.row,
            let subscription = subscription?.validated(),
            let obj = dataController.itemAt(indexPath)
        else {
            return cellForEmpty(at: indexPath)
        }

        if obj.type == .message {
            if obj.message?.validated() != nil {
                return cellForMessage(obj, at: indexPath)
            } else {
                return cellForEmpty(at: indexPath)
            }
        }

        if obj.type == .daySeparator {
            return cellForDaySeparator(obj, at: indexPath)
        }

        if obj.type == .unreadSeparator {
            return cellForUnreadSeparator(obj, at: indexPath)
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

    func cellForEmpty(at indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: kEmptyCellIdentifier, for: indexPath) {
            return cell
        }

        return UICollectionViewCell()
    }

    func cellForMessage(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatMessageCell.identifier,
            for: indexPath
        ) as? ChatMessageCell else {
            return cellForEmpty(at: indexPath)
        }

        cell.delegate = self

        if let message = obj.message {
            cell.message = message
        }

        cell.sequential = dataController.hasSequentialMessageAt(indexPath)

        return cell
    }

    func cellForDaySeparator(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatMessageDaySeparator.identifier,
            for: indexPath
        ) as? ChatMessageDaySeparator else {
            return cellForEmpty(at: indexPath)
        }

        cell.labelTitle.text = RCDateFormatter.date(obj.timestamp)
        return cell
    }

    func cellForUnreadSeparator(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatMessageUnreadSeparator.identifier,
            for: indexPath
        ) as? ChatMessageUnreadSeparator else {
            return cellForEmpty(at: indexPath)
        }

        cell.labelTitle.text = localized("chat.unread_separator")
        return cell
    }

    func cellForChannelHeader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatChannelHeaderCell.identifier,
            for: indexPath
        ) as? ChatChannelHeaderCell else {
            return cellForEmpty(at: indexPath)
        }

        cell.subscription = subscription
        return cell
    }

    func cellForDMHeader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatDirectMessageHeaderCell.identifier,
            for: indexPath
        ) as? ChatDirectMessageHeaderCell else {
            return cellForEmpty(at: indexPath)
        }
        cell.subscription = subscription
        return cell
    }

    func cellForLoader(_ obj: ChatData, at indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView?.dequeueReusableCell(
            withReuseIdentifier: ChatLoaderCell.identifier,
            for: indexPath
        ) as? ChatLoaderCell else {
            return cellForEmpty(at: indexPath)
        }

        return cell
    }

}

// MARK: UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let subscription = subscription?.validated() else {
            return .zero
        }

        var fullWidth = collectionView.frame.size.width

        if #available(iOS 11, *) {
            fullWidth -= collectionView.safeAreaInsets.right + collectionView.safeAreaInsets.left
        }

        if let obj = dataController.itemAt(indexPath) {
            if let value = dataController.dataCellHeight[obj.identifier] {
                return CGSize(width: fullWidth, height: value)
            }

            if let value = sizeForChatObject(obj, subscription: subscription, fullWidth: fullWidth) {
                return value
            }

            if let message = obj.message {
                guard !message.markedForDeletion else { return .zero }

                let sequential = dataController.hasSequentialMessageAt(indexPath)
                let height = ChatMessageCell.cellMediaHeightFor(message: message, width: fullWidth, sequential: sequential)
                dataController.cacheCellHeight(for: obj.identifier, value: height)
                return CGSize(width: fullWidth, height: height)
            }
        }

        return CGSize(width: fullWidth, height: 40)
    }

    func sizeForChatObject(_ obj: ChatData, subscription: Subscription, fullWidth: CGFloat) -> CGSize? {
        if obj.type == .header {
            let isDirectMessage = subscription.type == .directMessage
            let directMessageHeaderSize = CGSize(width: fullWidth, height: ChatDirectMessageHeaderCell.minimumHeight)
            let channelHeaderSize = CGSize(width: fullWidth, height: ChatChannelHeaderCell.minimumHeight)
            return isDirectMessage ? directMessageHeaderSize : channelHeaderSize
        }

        if obj.type == .loader {
            return CGSize(width: fullWidth, height: ChatLoaderCell.minimumHeight)
        }

        if obj.type == .daySeparator {
            return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
        }

        if obj.type == .unreadSeparator {
            if dataController.dismissUnreadSeparator {
                return CGSize(width: fullWidth, height: 0)
            }

            return CGSize(width: fullWidth, height: ChatMessageUnreadSeparator.minimumHeight)
        }

        return nil
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

        resetScrollToBottomButtonPosition()
    }
}

// MARK: ChatPreviewModeViewProtocol

extension ChatViewController: ChatPreviewModeViewProtocol {

    func userDidJoinedSubscription() {
        guard let auth = AuthManager.isAuthenticated() else { return }
        guard let subscription = self.subscription else { return }

        Realm.executeOnMainThread({ realm in
            subscription.auth = auth
            realm.add(subscription, update: true)
        })

        self.subscription = subscription
        updateJoinedView()
    }

}

// MARK: Block Message Sending

extension ChatViewController {

    private func updateMessageSendingPermission() {
        guard
            let subscription = subscription,
            let currentUser = AuthManager.currentUser(),
            let username = currentUser.username
        else {
            allowMessageSending()
            return
        }

        if subscription.roomReadOnly && subscription.roomOwner != currentUser && !currentUser.hasPermission(.postReadOnly, subscription: subscription) {
            blockMessageSending(reason: localized("chat.read_only"))
        } else if subscription.roomMuted.contains(username) {
            blockMessageSending(reason: localized("chat.muted"))
        } else {
            allowMessageSending()
        }
    }

    private func blockMessageSending(reason: String) {
        textInputbar.textView.placeholder = reason
        textInputbar.backgroundColor = view.theme?.backgroundColor ?? .white
        textInputbar.isUserInteractionEnabled = false
        leftButton.isEnabled = false
        rightButton.isEnabled = false
    }

    private func allowMessageSending() {
        textInputbar.textView.placeholder = ""
        textInputbar.backgroundColor = view.theme?.focusedBackground ?? .backgroundWhite
        textInputbar.isUserInteractionEnabled = true
        leftButton.isEnabled = true
        rightButton.isEnabled = true
    }

}

// MARK: Alerter
extension ChatViewController {
    func alertAPIError(_ error: APIError) {
        switch error {
        case .version(let available, let required):
            let message = String(format: localized("alert.unsupported_feature.message"), available.description, required.description)
            alert(
                title: localized("alert.unsupported_feature.title"),
                message: message
            )
        default:
            break
        }
    }
}

// MARK: KeyboardFrameViewDelegate

extension ChatViewController: KeyboardFrameViewDelegate {
    func keyboardDidChangeFrame(frame: CGRect?) {
        if let frame = frame {
            updateKeyboardConstraints(frame: frame)
        }
        resetScrollToBottomButtonPosition()
    }

    var keyboardProxyView: UIView? {
        return textInputbar.inputAccessoryView.superview
    }
}

extension ChatViewController: SocketConnectionHandler {

    func socketDidChangeState(state: SocketConnectionState) {
        Log.debug("[ChatViewController] socketDidChangeState: \(state)")
        chatTitleView?.state = state

        if state == .connected {
            loadMoreMessagesFrom(date: nil, loadRemoteHistory: true)
        }
    }

}

// MARK: NavigationBar Transparency

extension ChatViewController: PopPushDelegate, NavigationBarTransparency {
    var isNavigationBarTransparent: Bool {
        return false
    }
}

// MARK: UIPreviewActions

extension ChatViewController {
    override var previewActionItems: [UIPreviewActionItem] {
        guard let subscription = subscription, subscription.open else { return [] }

        let read = UIPreviewAction(title: localized("chat.preview.actions.read"), style: .default) { (_, _) in
            API.current()?.client(SubscriptionsClient.self).markRead(subscription: subscription)
        }

        let unread = UIPreviewAction(title: localized("chat.preview.actions.unread"), style: .default) { (_, _) in
            API.current()?.client(SubscriptionsClient.self).markUnread(subscription: subscription)
        }

        let favoriteTitle = subscription.favorite ? "chat.preview.actions.unfavorite" : "chat.preview.actions.favorite"
        let favorite = UIPreviewAction(title: localized(favoriteTitle), style: .default) { (_, _) in
            API.current()?.client(SubscriptionsClient.self).favoriteSubscription(subscription: subscription)
        }

        let hide = UIPreviewAction(title: localized("chat.preview.actions.hide"), style: .destructive) { (_, _) in
            API.current()?.client(SubscriptionsClient.self).hideSubscription(subscription: subscription)
        }

        var actions = [UIPreviewActionItem]()

        if subscription.alert {
            actions.append(read)
        } else {
            actions.append(unread)
        }

        actions.append(contentsOf: [favorite, hide])

        return actions
    }
}

// MARK: Themeable

extension ChatViewController {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = view.theme else { return }
        let themeName = ThemeManager.themes.first { $0.theme == theme }?.title
        let scrollToBottomImageName = "Float Button " + (themeName ?? "light")
        buttonScrollToBottom.setImage(UIImage(named: scrollToBottomImageName), for: .normal)

        if let backgroundImageViewEmptyState = backgroundImageViewEmptyState {
            backgroundImageViewEmptyState.image = UIImage(named: "Empty State \(themeName ?? "light")")
        }

        updateMessageSendingPermission()
    }
}
