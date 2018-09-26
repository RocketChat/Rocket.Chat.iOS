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

    // MARK: Data Manipulation

    internal var data: [AnyChatSection] = [] {
        didSet {
            onDataChanged?()
        }
    }

    internal var subscription: Subscription? {
        didSet {
            guard let subscription = subscription?.validated() else { return }
            messagesQuery = subscription.fetchMessagesQueryResults()
            messagesQueryToken = messagesQuery?.observe(handleDataUpdates)
            fetchMessages(from: nil)
        }
    }

    internal var messagesQueryToken: NotificationToken?
    internal var messagesQuery: Results<Message>?
    internal var onDataChanged: VoidCompletion?

    internal var lastSeen = Date()
    internal var requestingData = false
    internal var hasMoreData = true

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
     Returns the instance of MessageSection in the data
     if present. The index of the list is based in the section
     of the indexPath instance.

     - parameters:
        - indexPath: The indexPath of the item for lookup.
     - returns: The instance of AnyChatSection if exists.
     */
    func itemAt(_ indexPath: IndexPath) -> AnyChatSection? {
        guard data.count > indexPath.section else {
            return nil
        }

        return data[indexPath.section]
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
    func section(for message: Message, previous: AnyChatSection? = nil) -> AnyChatSection? {
        guard let message = message.validated()?.unmanaged else { return nil }

        var messageSectionModel = MessageSectionModel(message: message)

        if let previous = previous, let previousObject = previous.base.object.base as? MessageSectionModel {
            let previousMessage = previousObject.message

            let sequential = isSequential(message: message, previousMessage: previousMessage)
            messageSectionModel.isSequential = sequential

            let separator = daySeparator(message: message, previousMessage: previousMessage)
            messageSectionModel.daySeparator = separator
        }

        return AnyChatSection(MessageSection(
            object: AnyDifferentiable(messageSectionModel)
        ))
    }

    func handleDataUpdates(changes: RealmCollectionChange<Results<Message>>) {
        var updatedData: [AnyChatSection] = []

        var previousSection: AnyChatSection?
        messagesQuery?.forEach({ (object) in
            if let section = section(for: object, previous: previousSection) {
                updatedData.append(section)
                previousSection = section
            }
        })

        // RKS NOTE: Apply loader to the latest object
        // has more data.

        data = updatedData
    }

    internal var oldestMessageDateBeingPresented: Date? {
        if let object = data.last?.base.object.base as? MessageSectionModel {
            return object.message.createdAt
        }

        return nil
    }

    func fetchMessages(from oldestMessage: Date?) {
        guard !requestingData, hasMoreData else { return }
        guard let subscription = subscription?.validated()?.unmanaged else { return }

        requestingData = true
        MessageManager.getHistory(subscription, lastMessageDate: oldestMessage) { [weak self] oldest in
            DispatchQueue.main.async {
                self?.requestingData = false
                self?.hasMoreData = oldest != nil
            }
        }
    }

    // MARK: Data Manipulation

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
        guard
            let createdAt = message.createdAt,
            let previousCreatedAt = previousMessage.createdAt
        else {
            return nil
        }

        if createdAt.sameDayAs(previousCreatedAt) {
            return nil
        }

        return message.createdAt
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

        guard let date = message.createdAt, let prevDate = previousMessage.createdAt else {
            return false
        }

        let sameUser = message.user == previousMessage.user

        var timeLimit = AuthSettingsDefaults.messageGroupingPeriod
        if let settings = AuthSettingsManager.settings {
            timeLimit = settings.messageGroupingPeriod
        }

        return sameUser && Int(date.timeIntervalSince(prevDate)) < timeLimit
    }

}
