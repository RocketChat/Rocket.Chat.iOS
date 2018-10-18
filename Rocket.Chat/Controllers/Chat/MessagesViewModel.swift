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

final class MessagesViewModel {

    /**
     The array of values cached and already manipulated on this view model. This
     array is feeded from the Realm query, the observers on the query and the manipulations
     that are executed after getting the data.
     */
    internal var data: [AnyChatSection] = []
    internal var dataSorted: [AnyChatSection] = []

    /**
     The controller context that will be used to respond
     delegates from the cells.
     */
    weak var controllerContext: UIViewController?

    internal var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else { return }
            lastSeen = subscription.lastSeen ?? Date()
            subscribe(for: subscription)
            messagesQuery = subscription.fetchMessagesQueryResults()
            messagesQueryToken = messagesQuery?.observe(handleDataUpdates)
            fetchMessages(from: nil)
        }
    }

    // Variables required to fetch the messages of the Subscription
    // to the view model.
    internal var messagesQueryToken: NotificationToken?
    internal var messagesQuery: Results<Message>?

    /**
     This block is going to be called every time there's
     an update in the data of the view model.
     */
    internal var onDataChanged: VoidCompletion?

    /**
     Last time user read the messages from the Subscription from this view model.
     */
    internal var lastSeen = Date()

    /**
     If the view model is requesting new data from the API.
     */
    internal var requestingData = false

    /**
     If there's more data to be fetched from the API.
     */
    internal var hasMoreData = true

    // MARK: Life Cycle Controls

    init(controllerContext: UIViewController? = nil) {
        self.controllerContext = controllerContext
    }

    deinit {
        messagesQueryToken?.invalidate()

        if let subscription = subscription?.validated() {
            unsubscribe(for: subscription)
        }
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
    internal func unsubscribe(for subscription: Subscription) {
        SocketManager.unsubscribe(eventName: subscription.rid)
        SocketManager.unsubscribe(eventName: "\(subscription.rid)/deleteMessage")
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
        requestingData = false
    }

    /**
     Returns the specific cell item model for the IndexPath requested.
     */
    func item(for indexPath: IndexPath) -> AnyChatItem? {
        guard
            indexPath.section < dataSorted.count,
            indexPath.row < dataSorted[indexPath.section].viewModels().count
        else {
            return nil
        }

        let section = dataSorted[indexPath.section]
        return section.viewModels()[indexPath.row]
    }

    /**
     Creates the AnyChatSection object based on an instance of Message
     and set some attributes based on the previous message (if any) such like:
     if the message is sequential, if there's any separator to be added
     and more.

     - parameters:
        - message: The message object present in the section.
        - previous: The previous section to be presented before this one on the list.
     - returns: AnyChatSection instance based on MessageSectionModel.
    */
    func section(for message: UnmanagedMessage) -> AnyChatSection? {
        let messageSectionModel = MessageSectionModel(message: message)

        return AnyChatSection(MessageSection(
            object: AnyDifferentiable(messageSectionModel),
            controllerContext: controllerContext
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
        case .error(let error):
            fatalError("\(error)")
        }
    }

    /**
     Handle all deletions from Realm observer on the messages query.
     */
    internal func handle(deletions: [Int], on messagesQuery: Results<Message>) {
        for deletion in deletions where deletion < data.count {
            data.remove(at: deletion)
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

            if let section = section(for: message) {
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
                        object.differenceIdentifier == message.identifier &&
                        !message.isContentEqual(to: object.message)
                }

                return false
            })

            if let index = index {
                if let newSection = section(for: message) {
                    data[index] = newSection
                }
            } else {
                continue
            }
        }
    }

    /**
     This method will return the oldest date present in the list of messages. This is
     the data cached in the view model and not in the database.
     */
    internal var oldestMessageDateBeingPresented: Date? {
        if let object = data.last?.base.object.base as? MessageSectionModel {
            return object.message.createdAt
        }

        return nil
    }

    /**
     This method requests a new page of messages to the API. If the view model
     already detected that there's no more data to fetch, or it's currently
     fetching a new page, the method won't be executed.

     - parameters:
        - oldestMessage: This is the parameter that will be sent to the server in
            order to get the correct page of data.
     */
    func fetchMessages(from oldestMessage: Date?) {
        guard !requestingData, hasMoreData else { return }
        guard let subscription = subscription?.validated() else { return }
        guard let subscriptionUnmanaged = subscription.unmanaged else { return }

        let messagesFromDatabase = subscription.fetchMessages(30, lastMessageDate: oldestMessage)
        messagesFromDatabase.forEach {
            guard
                let message = $0.validated()?.unmanaged,
                let section = section(for: message)
            else {
                return
            }

            data.append(section)
        }

        if messagesFromDatabase.count > 0 {
            updateData()
        }

        requestingData = true
        MessageManager.getHistory(subscriptionUnmanaged, lastMessageDate: oldestMessage) { [weak self] oldest in
            DispatchQueue.main.async {
                self?.requestingData = false
                self?.hasMoreData = oldest != nil
            }
        }
    }

    // MARK: Data Manipulation

    /**
     This method updates the dataSorted array property with the correct
     sorting and also the properties related to sequential messages, day
     separators and unread marks.
     */
    internal func updateData() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.cacheDataSorted()
            self?.normalizeDataSorted()

            DispatchQueue.main.async {
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
     Anything related to the section that refers to sequential messages, day separators
     and unread marks is done on this method. A loop in the whole list of messages
     is executed on every update to make sure that there's no duplicated separators
     and everything looks good to the user on the final result.
     */
    internal func normalizeDataSorted() {
        let dataSortedMaxIndex = dataSorted.count - 1

        for (idx, object) in dataSorted.enumerated() {
            guard
                idx < dataSortedMaxIndex,
                let messageSection1 = object.object.base as? MessageSectionModel,
                let messageSection2 = dataSorted[idx + 1].object.base as? MessageSectionModel
            else {
                continue
            }

            let message = messageSection1.message
            let previousMessage = messageSection2.message

            let section = MessageSectionModel(
                message: message,
                daySeparator: daySeparator(message: message, previousMessage: previousMessage),
                sequential: isSequential(message: message, previousMessage: previousMessage)
            )

            dataSorted[idx] = AnyChatSection(MessageSection(
                object: AnyDifferentiable(section),
                controllerContext: controllerContext
            ))
        }
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
        guard message.groupable && previousMessage.groupable else {
            return false
        }

        if (message.markedForDeletion, previousMessage.markedForDeletion) != (false, false) {
            return false
        }

        if (message.failed, previousMessage.failed) != (false, false) {
            return false
        }

        let date = message.createdAt
        let prevDate = previousMessage.createdAt

        let sameUser = message.userIdentifier == previousMessage.userIdentifier

        var timeLimit = AuthSettingsDefaults.messageGroupingPeriod
        if let settings = AuthSettingsManager.settings {
            timeLimit = settings.messageGroupingPeriod
        }

        return sameUser && Int(date.timeIntervalSince(prevDate)) < timeLimit
    }
}

extension MessagesViewModel {

    func sendTextMessage(text: String) {
        guard let subscription = subscription?.validated()?.unmanaged, text.count > 0 else {
            return
        }

        guard let client = API.current()?.client(MessagesClient.self) else { return Alert.defaultError.present() }
        client.sendMessage(text: text, subscription: subscription)
    }

    func editTextMessage(_ message: Message, text: String) {
        guard let client = API.current()?.client(MessagesClient.self) else { return Alert.defaultError.present() }
        client.updateMessage(message, text: text)
    }

}
