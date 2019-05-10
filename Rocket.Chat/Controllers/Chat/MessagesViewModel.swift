//
//  MessagesViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 25/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import DifferenceKit
import RocketChatViewController

// swiftlint:disable type_body_length file_length
final class MessagesViewModel {

    /**
     The array of values cached and already manipulated on this view model. This
     array is feeded from the Realm query, the observers on the query and the manipulations
     that are executed after getting the data.
     */
    internal var data: [AnyChatSection] = []
    internal var dataSorted: [AnyChatSection] = [] {
        didSet {
            let dataSorted = self.dataSorted

            recentSendersDataQueue.addOperation { [weak self] in
                guard let self = self else {
                    return
                }

                var seen = Set<String>()
                let senders = dataSorted.compactMap { data -> String? in
                    guard
                        let message = data.object.base as? MessageSectionModel,
                        let username = message.message.user?.username
                    else {
                        return nil
                    }

                    if !seen.contains(username) {
                        seen.insert(username)
                        return username
                    }

                    return nil
                }

                self.recentSenders = Array(senders[0..<min(senders.count, 5)])
            }
        }
    }

    internal var dataNormalized: [ArraySection<AnyChatSection, AnyChatItem>] = []

    /**
     The controller context that will be used to respond
     delegates from the cells.
     */
    var currentTheme: Theme = .light
    weak var controllerContext: UIViewController? {
        didSet {
            currentTheme = controllerContext?.view.theme ?? .light
        }
    }

    /**
     A compilation of the 5 last message senders usernames
     to be used for autocompletion priorization.
    */
    var recentSenders = [String]()

    /**
     Subscription object to be used in all queries and
     requests. This value can be nil if the controller is actually
     presenting a Thread.
    */
    internal var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else { return }

            rid = subscription.rid
            lastSeen = lastSeen == nil ? subscription.lastSeen : lastSeen
            subscribe(for: subscription)
            messagesQuery = subscription.fetchMessagesQueryResults()
            refreshMessagesQueryOldValues()
            messagesQueryToken = messagesQuery?.observe({ [weak self] collectionChanges in
                self?.handleDataUpdates(changes: collectionChanges)
            })

            fetchMessages(from: nil)
        }
    }

    // Pagination properties on this view model, currently only
    // being used to load messages from a thread.
    internal let pageSize = 30
    internal var currentPage = 0
    internal var showing = 0
    internal var total = 0

    /**
     Thread identifier that will be used to present all messages
     related to a thread.
    */
    internal var threadIdentifier: String? {
        didSet {
            guard
                let threadIdentifier = threadIdentifier,
                let message = Message.find(withIdentifier: threadIdentifier),
                let subscription = Subscription.find(rid: message.rid)
            else {
                return
            }

            subscribe(for: subscription)
            messagesQuery = subscription.fetchMessagesQueryResultsFor(threadIdentifier: threadIdentifier)
            refreshMessagesQueryOldValues()
            messagesQueryToken = messagesQuery?.observe({ [weak self] collectionChanges in
                self?.handleDataUpdates(changes: collectionChanges)
            })

            fetchThreadMessages(from: nil)
        }
    }

    // Thread safe reference to rid. This variable is required to
    // setup the HeaderSection
    internal var rid: String = ""

    // Variables required to fetch the messages of the Subscription
    // to the view model.
    internal var messagesQueryToken: NotificationToken?
    internal var messagesQueryOldValues: [AnyHashable] = []
    internal var messagesQuery: Results<Message>?

    /**
     This block is going to be called every time there's
     an update in the data of the view model. This is not
     called in the main thread.
     */
    internal var onDataChanged: VoidCompletion?

    /**
     Last time user read the messages from the Subscription from this view model.
     */
    internal var lastSeen: Date?
    internal var hasUnreadMarker = false
    internal var unreadMarkerObjectIdentifier: String?

    /**
     If the view model is requesting new data from the API.
     */
    enum RequestingDataType {
        case none
        case initialRequest
        case historyRequest
    }

    internal var onRequestingDataChanged: ((RequestingDataType) -> Void)?
    internal var requestingData: RequestingDataType = .none {
        didSet {
            onRequestingDataChanged?(requestingData)
        }
    }

    /**
     If there's more data to be fetched from the API.
     */
    internal var hasMoreData = true

    /**
     The oldest message requested from the API at the moment.
     */
    internal var oldestMessageDateFromRemote: Date?

    /**
     The OperationQueue responsible for sorting the data
     and organizing it. Operation is required to prevent
     manipulating data that was changed.
     */
    private let updateDataQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        return operationQueue
    }()

    /**
     This OperationQueue responsible for updating the recent
     usernames that sent messages.
     */
    private let recentSendersDataQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        return operationQueue
    }()

    /**
     The OperationQueue responsible for querying the data from Realm.
     */
    private let queryDataQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .userInteractive
        return operationQueue
    }()

    // MARK: Life Cycle Controls

    init(controllerContext: UIViewController? = nil) {
        self.controllerContext = controllerContext
    }

    internal func destroy() {
        messagesQueryToken?.invalidate()
        unsubscribe()
    }

    deinit {
        destroy()
    }

    // MARK: Subscriptions Control

    /**
     This method enables all kind of updates related to the messages
     of the subscription attached to the view model.
     */
    internal func subscribe(for subscription: Subscription) {
        MessageManager.changes(subscription)
        MessageManager.subscribeDeleteMessage(subscription)
    }

    /**
     This method will remove all the subscriptions related to
     messages of the subscription attached to the view model.
     */
    internal func unsubscribe() {
        guard !rid.isEmpty else { return }
        SocketManager.unsubscribe(eventName: rid)
        SocketManager.unsubscribe(eventName: "\(rid)/deleteMessage")
    }

    // MARK: Data

    /**
     The number of cached sections present in the list.
     */
    var numberOfSections: Int {
        return data.count
    }

    /**
     Removes all the cached data from the data controller instance and
     resets all properties that needs to be reset in order to get a clean
     state in the view.
     */
    func clear() {
        data = []
        hasMoreData = true
        requestingData = .none
    }

    func sectionIndex(for item: AnyChatItem) -> Int? {
        let section = dataSorted.filter({ $0.viewModels().contains(where: { $0.differenceIdentifier == item.differenceIdentifier }) }).first
        if let section = section {
            return dataSorted.firstIndex(of: section)
        }

        return nil
    }

    func section(for index: Int) -> AnyChatSection? {
        guard index < dataSorted.count else {
            return nil
        }

        return dataSorted[index]
    }

    /**
     Returns the specific cell item model for the IndexPath requested.
     */
    func item(for indexPath: IndexPath) -> AnyChatItem? {
        guard indexPath.section < dataSorted.count else {
            return nil
        }

        let viewModels = dataSorted[indexPath.section].viewModels()

        guard indexPath.row < viewModels.count else {
            return nil
        }

        return viewModels[indexPath.row]
    }

    /**
     Creates the AnyChatSection object based on an instance of Message.

     - parameters:
        - message: The message object present in the section.
     - returns: AnyChatSection instance based on MessageSectionModel.
    */
    func section(for message: UnmanagedMessage) -> AnyChatSection? {
        if let existingSection = dataNormalized.filter({ $0.model.differenceIdentifier == AnyHashable(message.differenceIdentifier) }).first {
            let messageSectionModel: MessageSectionModel
            if let existingSectionModel = existingSection.model.base.object.base as? MessageSectionModel {
                messageSectionModel = MessageSectionModel(
                    message: message,
                    daySeparator: existingSectionModel.daySeparator,
                    sequential: existingSectionModel.isSequential,
                    unreadIndicator: unreadMarkerObjectIdentifier == message.identifier,
                    loader: existingSectionModel.containsLoader
                )
            } else {
                messageSectionModel = MessageSectionModel(message: message)
            }

            return AnyChatSection(MessageSection(
                object: AnyDifferentiable(messageSectionModel),
                controllerContext: controllerContext,
                collapsibleItemsState: (existingSection.model.base as? MessageSection)?.collapsibleItemsState ?? [:],
                compressedLayout: threadIdentifier?.isEmpty ?? true
            ))
        }

        return AnyChatSection(MessageSection(
            object: AnyDifferentiable(MessageSectionModel(message: message)),
            controllerContext: controllerContext,
            collapsibleItemsState: [:],
            compressedLayout: threadIdentifier?.isEmpty ?? true
        ))
    }

    /**
     This method is called on every update the messagesQuery get from Realm.
    */
    internal func handleDataUpdates(changes: RealmCollectionChange<Results<Message>>) {
        guard let messagesQuery = self.messagesQuery else { return }

        switch changes {
        case .initial:
            // Ignore the initial query, since we're firing the initial results directly
            // on the fetchMessages() query when this query is created.
            break

        case .update(_, let deletions, let insertions, let modifications):
            handle(deletions: deletions, on: messagesQuery)
            handle(insertions: insertions, on: messagesQuery)
            handle(modifications: modifications, on: messagesQuery)
            updateData()
            refreshMessagesQueryOldValues()

        case .error(let error):
            fatalError("\(error)")
        }
    }

    /**
     Caches the ids of the objects in the messagesQuery before the last update.
     It's used to identify deletions without having to mirror query
     indexes on the processed data properties
     */
    func refreshMessagesQueryOldValues() {
        guard let messagesQuery = messagesQuery else {
            return
        }

        messagesQueryOldValues = messagesQuery.compactMap({ message -> AnyHashable? in
            guard let id = message.identifier else {
                return nil
            }

            return AnyHashable(id)
        })
    }

    /**
     Handle all deletions from Realm observer on the messages query.
     */
    internal func handle(deletions: [Int], on messagesQuery: Results<Message>) {
        for deletion in deletions {
            guard
                deletion < messagesQueryOldValues.count
            else {
                continue
            }

            let deletionId = messagesQueryOldValues[deletion]
            if let index = data.firstIndex(where: {$0.differenceIdentifier == deletionId}) {
                data.remove(at: index)
            }
        }
    }

    /**
     Handle all insertions from Realm observer on the messages query.
     */
    internal func handle(insertions: [Int], on messagesQuery: Results<Message>) {
        for insertion in insertions {
            guard
                insertion < messagesQuery.count,
                let message = messagesQuery[insertion].validated()?.unmanaged
            else {
                continue
            }

            let index = data.firstIndex(where: { (section) -> Bool in
                if let object = section.object.base as? MessageSectionModel {
                    return object.differenceIdentifier == message.identifier
                }

                return false
            })

            if index != nil {
                return
            } else if let section = section(for: message) {
                data.append(section)
            }
        }
    }

    /**
     Handle all modifications from Realm observer on the messages query.
     */
    internal func handle(modifications: [Int], on messagesQuery: Results<Message>) {
        for modified in modifications {
            guard
                modified < messagesQuery.count,
                let message = messagesQuery[modified].validated()?.unmanaged
            else {
                continue
            }

            let index = data.firstIndex(where: { (section) -> Bool in
                if let object = section.object.base as? MessageSectionModel {
                    return
                        object.differenceIdentifier == message.identifier
                }

                return false
            })

            if let index = index {
                if let newSection = section(for: message) {
                    MessageTextCacheManager.shared.update(for: message)
                    data[index] = newSection
                    if let indexOfDataSorted = dataSorted.firstIndex(of: newSection) {
                        dataSorted[indexOfDataSorted] = newSection
                    }
                }
            } else {
                continue
            }
        }
    }

    /**
     This method requests a new page of messages to the API. If the view model
     already detected that there's no more data to fetch, or it's currently
     fetching a new page, the method won't be executed.

     - parameters:
        - oldestMessage: This is the parameter that will be sent to the server in
            order to get the correct page of data.
     */
    // swiftlint:disable function_body_length
    func fetchMessages(from oldestMessage: Date?, prepareAnotherPage: Bool = true) {
        guard
            requestingData == .none,
            hasMoreData || oldestMessage == nil,
            let subscription = subscription?.validated(),
            let subscriptionUnmanaged = subscription.unmanaged
        else {
            return
        }

        requestingData = oldestMessage == nil ? .initialRequest : .historyRequest

        queryDataQueue.addOperation { [weak self] in
            guard
                let self = self,
                let subscriptionValid = Subscription.find(rid: subscriptionUnmanaged.rid)
            else {
                return
            }

            let messagesFromDatabase = subscriptionValid.fetchMessages(self.pageSize, lastMessageDate: oldestMessage)
            messagesFromDatabase.forEach {
                guard let message = $0.validated()?.unmanaged else { return }

                let index = self.data.firstIndex(where: { (section) -> Bool in
                    if let object = section.object.base as? MessageSectionModel {
                        return object.differenceIdentifier == message.identifier
                    }

                    return false
                })

                if index != nil {
                    return
                } else if let section = self.section(for: message) {
                    self.data.append(section)
                }
            }

            if messagesFromDatabase.count > 0 {
                self.updateData()

                if prepareAnotherPage {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                        self?.fetchMessages(
                            from: self?.oldestMessageDateFromRemote,
                            prepareAnotherPage: false
                        )
                    })
                }
            }
        }

        let client = API.current()?.client(SubscriptionsClient.self)
        client?.loadHistory(
            subscription: subscription,
            latest: oldestMessage
        ) { [weak self] oldest in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.requestingData = .none
                self.hasMoreData = oldest != nil

                if let oldest = oldest {
                    self.oldestMessageDateFromRemote = oldest
                } else {
                    self.updateData()
                }
            }
        }
    }

    /**
     This method requests a new page of thread messages to the API. If the view model
     already detected that there's no more data to fetch, or it's currently
     fetching a new page, the method won't be executed.

     - parameters:
     - oldestMessage: This is the parameter that will be sent to the server in
     order to get the correct page of data.
     */
    // swiftlint:disable function_body_length cyclomatic_complexity
    func fetchThreadMessages(from oldestMessage: Date?, prepareAnotherPage: Bool = true) {
        guard
            requestingData == .none,
            hasMoreData,
            let threadIdentifier = threadIdentifier
        else {
            return
        }

        requestingData = oldestMessage == nil ? .initialRequest : .historyRequest

        queryDataQueue.addOperation { [weak self] in
            guard
                let self = self,
                let mainMessage = Message.find(withIdentifier: threadIdentifier),
                let subscriptionValid = Subscription.find(rid: mainMessage.rid)
            else {
                return
            }

            let messagesFromDatabase = subscriptionValid.fetchMessages(
                self.pageSize,
                lastMessageDate: oldestMessage,
                threadIdentifier: threadIdentifier
            )

            messagesFromDatabase.forEach {
                guard let message = $0.validated()?.unmanaged else { return }

                let index = self.data.firstIndex(where: { (section) -> Bool in
                    if let object = section.object.base as? MessageSectionModel {
                        return object.differenceIdentifier == message.identifier
                    }

                    return false
                })

                if index != nil {
                    return
                } else if let section = self.section(for: message) {
                    self.data.append(section)
                }
            }

            if messagesFromDatabase.count > 0 {
                self.updateData()

                if prepareAnotherPage {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [weak self] in
                        self?.fetchThreadMessages(
                            from: self?.oldestMessageDateFromRemote,
                            prepareAnotherPage: false
                        )
                    })
                }
            }
        }

        let request = ThreadMessagesRequest(tmid: threadIdentifier)
        let options: APIRequestOptionSet = [.paginated(count: pageSize, offset: currentPage * pageSize)]

        API.current()?.fetch(request, options: options) { [weak self] response in
            DispatchQueue.main.async { [weak self] in
                guard
                    let self = self,
                    case let .resource(resource) = response
                else {
                    return
                }

                self.oldestMessageDateFromRemote = resource.messages.last?.createdAt

                self.showing += resource.count ?? 0
                self.total = resource.total ?? 0
                self.currentPage += 1

                self.requestingData = .none
                self.hasMoreData = self.showing < self.total

                // Persist messages in database
                Realm.current?.execute({ realm in
                    for message in resource.raw?["messages"].array ?? [] {
                        let managedMessage = Message()
                        managedMessage.map(message, realm: realm)
                        realm.add(managedMessage, update: true)
                    }
                })

                // Update data into the UI
                self.updateData()
            }
        }
    }

    // MARK: Data Manipulation

    /**
     This method updates the dataSorted array property with the correct
     sorting and also the properties related to sequential messages, day
     separators and unread marks.
     */
    internal func updateData(shouldUpdateUI: Bool = true) {
        updateDataQueue.addOperation { [weak self] in
            DispatchQueue.main.sync {
                self?.cacheDataSorted()
            }

            self?.markUnreadMarkerIfNeeded()
            self?.normalizeDataSorted()

            if shouldUpdateUI {
                self?.onDataChanged?()
            }
        }
    }

    /**
     Sort the data list based on data and cache it in a local variable.
     */
    internal func cacheDataSorted() {
        dataSorted = data.sorted { (section1, section2) -> Bool in
            guard
                let object1 = section1.object.base as? MessageSectionModel,
                let object2 = section2.object.base as? MessageSectionModel
            else {
                return false
            }

            return object1.messageDate.compare(object2.messageDate) == .orderedDescending
        }
    }

    /**
     This method will mark the unread marker position
     for this subscription state and won't change until
     the user leaves the room.
     */
    internal func markUnreadMarkerIfNeeded() {
        // Unread marker will remain on the same message
        // all the time until user closes the screen.
        if unreadMarkerObjectIdentifier == nil {
            if let lastSeen = lastSeen {
                for object in dataSorted.reversed() {
                    guard let messageSection1 = object.object.base as? MessageSectionModel else { continue }

                    let message = messageSection1.message
                    let unreadMarker = !hasUnreadMarker && message.createdAt > lastSeen

                    if unreadMarker {
                        unreadMarkerObjectIdentifier = message.identifier
                        hasUnreadMarker = true
                        break
                    }
                }
            }
        }
    }

    /**
     Anything related to the section that refers to sequential messages, day separators
     and unread marks is done on this method. A loop in the whole list of messages
     is executed on every update to make sure that there's no duplicated separators
     and everything looks good to the user on the final result.
     */
    internal func normalizeDataSorted() {
        let dataSortedMaxIndex = dataSorted.count - 1

        for (idx, object) in dataSorted.enumerated() {
            guard let messageSection1 = object.object.base as? MessageSectionModel else { continue }

            let message = messageSection1.message
            let collpsibleItemsState = (object.base as? MessageSection)?.collapsibleItemsState ?? [:]

            var separator: Date?
            var sequential = false
            var loader = false

            if idx == dataSortedMaxIndex {
                loader = hasMoreData || requestingData != .none
            } else if let messageSection2 = dataSorted[idx + 1].object.base as? MessageSectionModel {
                separator = daySeparator(message: message, previousMessage: messageSection2.message)
                sequential = isSequential(message: message, previousMessage: messageSection2.message)
            }

            let section = MessageSectionModel(
                message: message,
                daySeparator: separator,
                sequential: sequential,
                unreadIndicator: unreadMarkerObjectIdentifier == message.identifier,
                loader: loader
            )

            let chatSection = AnyChatSection(MessageSection(
                object: AnyDifferentiable(section),
                controllerContext: controllerContext,
                collapsibleItemsState: collpsibleItemsState,
                compressedLayout: threadIdentifier?.isEmpty ?? true
            ))

            dataSorted[idx] = chatSection

            if let indexOfSection = data.firstIndex(of: chatSection) {
                data[indexOfSection] = chatSection
            }

            // Cache the processed result of the message text
            // on this loop to avoid doing that in the main thread.
            MessageTextCacheManager.shared.message(for: message, with: currentTheme)
        }

        let currentHeaderSection = AnyChatSection(
            AnyChatSection(
                HeaderSection(
                    object: AnyDifferentiable(HeaderChatItem(rid: rid)),
                    controllerContext: nil
                )
            )
        )

        if threadIdentifier == nil {
            let currentHeaderIndex = dataSorted.firstIndex(of: currentHeaderSection)
            if currentHeaderIndex == nil && !hasMoreData && requestingData == .none {
                data.append(currentHeaderSection)
                dataSorted.append(currentHeaderSection)
            } else if let currentHeaderIndex = currentHeaderIndex {
                dataSorted.remove(at: currentHeaderIndex)
                dataSorted.append(currentHeaderSection)
            }
        }

        dataNormalized = dataSorted.map({ ArraySection(model: $0, elements: $0.viewModels()) })
    }

    /**
     Returns if the message object is the first message of a day, and in this case
     returns the instance of the date. This is used in order to add the date separator
     in the list of messages.

     - parameters:
        - message: The main message object to be checked.
        - previousMessage: The previous message object to be compared.
     - returns: The day that needs to be displayed in the separator if any.
     */
    func daySeparator(message: UnmanagedMessage, previousMessage: UnmanagedMessage) -> Date? {
        let createdAt = message.createdAt
        let previousCreatedAt = previousMessage.createdAt

        if createdAt.sameDayAs(previousCreatedAt) {
            return nil
        }

        return createdAt
    }

    /**
     Returns if the message object is sequential or not, based on the previous message
     object. This method considers many variables: if the messages are groupable,
     the setting from the server that tells the maximum interval, if the message
     is failed and more.

     - parameters:
        - message: The main message object to be checked.
        - previousMessage: The previous message object to be compared.
     - returns: If the message is sequential.
     */
    func isSequential(message: UnmanagedMessage, previousMessage: UnmanagedMessage) -> Bool {
        // Being a reply thread, everything can be sequential if it's just following
        // the same thread.
        if message.isThreadReplyMessage && previousMessage.isThreadReplyMessage {
            return message.threadMessageId == previousMessage.threadMessageId
        }

        guard message.groupable && previousMessage.groupable else {
            return false
        }

        if (message.markedForDeletion, previousMessage.markedForDeletion) != (false, false) {
            return false
        }

        if (message.failed, previousMessage.failed) != (false, false) {
            return false
        }

        if previousMessage.isThreadReplyMessage || previousMessage.isThreadMainMessage {
            return false
        }

        let date = message.createdAt
        let prevDate = previousMessage.createdAt

        let sameUser = message.userIdentifier == previousMessage.userIdentifier
            && message.alias == previousMessage.alias

        var timeLimit = AuthSettingsDefaults.messageGroupingPeriod
        if let settings = AuthSettingsManager.settings {
            timeLimit = settings.messageGroupingPeriod
        }

        return sameUser && Int(date.timeIntervalSince(prevDate)) < timeLimit
    }
}

extension MessagesViewModel {

    func sendTextMessage(text: String, replyThreadIdentifier: String) {
        var rid: String?

        if let subscription = subscription?.validated()?.unmanaged {
            rid = subscription.rid
        } else if let thread = threadIdentifier, let message = Message.find(withIdentifier: thread) {
            rid = message.rid
        }

        guard
            let ridValidated = rid,
            let subscription = Subscription.find(rid: ridValidated)?.unmanaged,
            !text.isEmpty
        else {
            return
        }

        if let (command, params) = text.commandAndParams() {
            guard let client = API.current()?.client(CommandsClient.self) else {
                return Alert.defaultError.present()
            }

            client.runCommand(command: command, params: params, roomId: subscription.rid)
        } else {
            guard let client = API.current()?.client(MessagesClient.self) else {
                return Alert.defaultError.present()
            }

            let thread = replyThreadIdentifier.isEmpty ? threadIdentifier : replyThreadIdentifier
            client.sendMessage(text: text, subscription: subscription, threadIdentifier: thread)
        }
    }

    func editTextMessage(_ message: Message, text: String) {
        guard let client = API.current()?.client(MessagesClient.self) else { return Alert.defaultError.present() }
        client.updateMessage(message, text: text)
    }

}

extension AnyChatSection: Equatable {
    public static func == (lhs: AnyChatSection, rhs: AnyChatSection) -> Bool {
        return lhs.differenceIdentifier == rhs.differenceIdentifier
    }
}
