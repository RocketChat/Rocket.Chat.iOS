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
import AudioToolbox

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

    var showButtonScrollToBottom: Bool = false {
        didSet {
            self.buttonScrollToBottom.superview?.layoutIfNeeded()

            if self.showButtonScrollToBottom {
                self.buttonScrollToBottomMarginConstraint?.constant = -64
            } else {
                self.buttonScrollToBottomMarginConstraint?.constant = 50
            }

            if showButtonScrollToBottom != oldValue {
                UIView.animate(withDuration: 0.5) {
                    self.buttonScrollToBottom.superview?.layoutIfNeeded()
                }
            }
        }
    }

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
    var isWritingMessage: Bool = false
    var recorderManager: AudioMessageRecorder?

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

        collectionView?.isPrefetchingEnabled = true

        isInverted = false
        bounces = true
        shakeToClearEnabled = true
        isKeyboardPanningEnabled = true
        shouldScrollToBottomAfterKeyboardShows = false

        leftButton.setImage(UIImage(named: "Upload"), for: .normal)

        rightButton.isEnabled = false

        textInputbar.rightButton.layer.zPosition = 2

        recorderManager = AudioMessageRecorder()
        recorderManager?.set(recorderDelegate: self)

        removeToolbarRightButtonSelectors()
        setupToolbarRightButtonWithAudioRecorder()
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

        if buttonScrollToBottomMarginConstraint == nil {
            buttonScrollToBottomMarginConstraint = buttonScrollToBottom.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
            buttonScrollToBottomMarginConstraint?.isActive = true
        }
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

    fileprivate func setupToolbarRightButtonWithAudioRecorder() {
        removeToolbarRightButtonSelectors()

        textInputbar.rightButton.setImage(UIImage(named: "Microphone"), for: .normal)
        textInputbar.rightButton.setTitle("", for: .normal)

        textInputbar.rightButton.addTarget(self, action: #selector(recordAudioMessage), for: .touchDown)
        textInputbar.rightButton.addTarget(self, action: #selector(stopAudioRecord), for: .touchUpInside)
        textInputbar.rightButton.addTarget(self, action: #selector(stopAudioRecord), for: .touchCancel)
    }

    fileprivate func setupToolbarRightButtonWithMessageSender() {
        removeToolbarRightButtonSelectors()

        textInputbar.rightButton.setImage(UIImage(named: "Paper Plane"), for: .normal)
        textInputbar.rightButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }

    fileprivate func removeToolbarRightButtonSelectors() {
        textInputbar.rightButton.removeTarget(self, action: #selector(recordAudioMessage), for: .touchDown)
        textInputbar.rightButton.removeTarget(self, action: #selector(stopAudioRecord), for: .touchUpInside)
        textInputbar.rightButton.removeTarget(self, action: #selector(stopAudioRecord), for: .touchCancel)
        textInputbar.rightButton.removeTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }

    override class func collectionViewLayout(for decoder: NSCoder) -> UICollectionViewLayout {
        return ChatCollectionViewFlowLayout()
    }

    fileprivate func registerCells() {
        collectionView?.register(UINib(
            nibName: "ChatLoaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatLoaderCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatMessageDaySeparator",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatMessageDaySeparator.identifier)

        collectionView?.register(UINib(
            nibName: "ChatChannelHeaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatChannelHeaderCell.identifier)

        collectionView?.register(UINib(
            nibName: "ChatDirectMessageHeaderCell",
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: ChatDirectMessageHeaderCell.identifier)

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
        showButtonScrollToBottom = false
    }

    // MARK: SlackTextViewController

    override func canPressRightButton() -> Bool {
        return SocketManager.isConnected()
    }

    override func didPressRightButton(_ sender: Any?) {

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

            isWritingMessage = false
            setupToolbarRightButtonWithAudioRecorder()

        } else {
            SubscriptionManager.sendTypingStatus(subscription, isTyping: true)

            if !isWritingMessage {
                isWritingMessage = !isWritingMessage
                setupToolbarRightButtonWithMessageSender()
            }
        }
    }

    // MARK: Message
    @objc fileprivate func sendMessage() {
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

        isWritingMessage = false
        setupToolbarRightButtonWithAudioRecorder()
    }

    fileprivate func chatLogIsAtBottom() -> Bool {
        guard let collectionView = collectionView else { return false }

        let height = collectionView.bounds.height
        let bottomInset = collectionView.contentInset.bottom
        let scrollContentSizeHeight = collectionView.contentSize.height
        let verticalOffsetForBottom = scrollContentSizeHeight + bottomInset - height

        return collectionView.contentOffset.y >= (verticalOffsetForBottom - 1)
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

        collectionView?.performBatchUpdates({
            let indexPaths = self.dataController.clear()
            self.collectionView?.deleteItems(at: indexPaths)
        }, completion: { _ in
            CATransaction.commit()

            if self.closeSidebarAfterSubscriptionUpdate {
                MainChatViewController.closeSideMenuIfNeeded()
                self.closeSidebarAfterSubscriptionUpdate = false
            }
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
            guard case .update(_, _, let insertions, let modifications) = changes else {
                return
            }

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
                DispatchQueue.main.async {
                    let isAtBottom = self.chatLogIsAtBottom()
                    UIView.performWithoutAnimation {
                        self.collectionView?.performBatchUpdates({
                            self.collectionView?.reloadItems(at: indexPathModifications.map { IndexPath(row: $0, section: 0) })
                        }, completion: { _ in
                            if isAtBottom {
                                self.scrollToBottom()
                            }
                        })
                    }
                }
            }
        }
    }

    func loadHistoryFromRemote(date: Date?) {
        let tempSubscription = Subscription(value: self.subscription)

        MessageManager.getHistory(tempSubscription, lastMessageDate: date) { [weak self] messages in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.isRequestingHistory = false
                self?.loadMoreMessagesFrom(date: date, loadRemoteHistory: false)

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

    fileprivate func loadMoreMessagesFrom(date: Date?, loadRemoteHistory: Bool = true) {
        if isRequestingHistory || dataController.loadedAllMessages {
            return
        }

        isRequestingHistory = true

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
                        self?.loadHistoryFromRemote(date: date)
                    }
                } else {
                    self?.isRequestingHistory = false
                }
            })
        } else {
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

    fileprivate func appendMessages(messages: [Message], completion: VoidCompletion?) {
        guard !isAppendingMessages else { return }
        guard let collectionView = self.collectionView else { return }

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
                collectionView.performBatchUpdates({
                    let (indexPaths, removedIndexPaths) = self.dataController.insert(objs)
                    collectionView.insertItems(at: indexPaths)
                    collectionView.deleteItems(at: removedIndexPaths)
                }, completion: { _ in
                    self.isAppendingMessages = false
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

    @objc func chatTitleViewDidPressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "Channel Info", sender: sender)
    }

    @IBAction func buttonScrollToBottomPressed(_ sender: UIButton) {
        scrollToBottom(true)
    }

    // MARK: Right Button Background View

    var microphoneCircleView: UIView?

    fileprivate func createCircleView() -> UIView? {
        guard let imageViewFrameSize = textInputbar.rightButton.imageView?.frame.size else { return nil }

        let circleView = UIView(frame: CGRect(x: imageViewFrameSize.width / 2, y: imageViewFrameSize.height / 2, width: 0, height: 0))
        circleView.layer.cornerRadius = 65
        circleView.layer.zPosition = -1
        circleView.backgroundColor = view.tintColor

        UIView.animate(withDuration: 0.2) {
            circleView.frame.size = CGSize(width: 130, height: 130)
        }

        circleView.layer.anchorPoint = CGPoint(x: 1.0, y: 1.0)

        return circleView
    }

    // MARK: Audio Message Recorder Helpers

    @objc func recordAudioMessage() {
        microphoneCircleView = createCircleView()

        guard let circleView = microphoneCircleView else { return }

        textInputbar.rightButton.setTitleColor(UIColor.white, for: .highlighted)
        textInputbar.rightButton.tintColor = UIColor.white
        textInputbar.rightButton.addSubview(circleView)

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        recorderManager?.record()
    }

    @objc func stopAudioRecord() {
        if let circleView = microphoneCircleView {
            circleView.removeFromSuperview()
        }

        textInputbar.rightButton.tintColor = view.tintColor
        self.textView.resignFirstResponder()

        recorderManager?.stop()
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

        cell.sequential = dataController.hasSequentialMessageAt(indexPath)

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

extension ChatViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let fullWidth = collectionView.bounds.size.width

        if let obj = dataController.itemAt(indexPath) {
            if obj.type == .header {
                if subscription.type == .directMessage {
                    return CGSize(width: fullWidth, height: ChatDirectMessageHeaderCell.minimumHeight)
                } else {
                    return CGSize(width: fullWidth, height: ChatChannelHeaderCell.minimumHeight)
                }
            }

            if obj.type == .loader {
                return CGSize(width: fullWidth, height: ChatLoaderCell.minimumHeight)
            }

            if obj.type == .daySeparator {
                return CGSize(width: fullWidth, height: ChatMessageDaySeparator.minimumHeight)
            }

            if let message = obj.message {
                let sequential = dataController.hasSequentialMessageAt(indexPath)
                let height = ChatMessageCell.cellMediaHeightFor(message: message, sequential: sequential)
                return CGSize(width: fullWidth, height: height)
            }
        }

        return CGSize(width: fullWidth, height: 40)
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

        showButtonScrollToBottom = !chatLogIsAtBottom()
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
