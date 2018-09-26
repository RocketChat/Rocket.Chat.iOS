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
            loadHistoryRemotely()
        }
    }

    internal var messagesQueryToken: NotificationToken?
    internal var messagesQuery: Results<Message>?
    internal var onDataChanged: VoidCompletion?

    /**
     Removes all data from the data controller instance.
     */
    func clear() {
        data = []
    }

    /**
     Returns the instance of MessageSection in the data
     if present. The index of the list is based in the section
     of the indexPath instance.
     */
    func itemAt(_ indexPath: IndexPath) -> AnyChatSection? {
        guard data.count > indexPath.section else {
            return nil
        }

        return data[indexPath.section]
    }

    func section(for message: Message) -> AnyChatSection? {
        guard let message = message.validated()?.unmanaged else { return nil }
        let messageSectionModel = MessageSectionModel(message: message)
        let messageSection = MessageSection(object: AnyDifferentiable(messageSectionModel))
        return AnyChatSection(messageSection)
    }

    func handleDataUpdates(changes: RealmCollectionChange<Results<Message>>) {
        var updatedData: [AnyChatSection] = []

        messagesQuery?.forEach({ (object) in
            if let section = section(for: object) {
                updatedData.append(section)
            }
        })

        data = updatedData
    }

    func loadHistoryRemotely() {
        guard let subscription = subscription?.validated()?.unmanaged else { return }
        MessageManager.getHistory(subscription, lastMessageDate: nil) { _ in

        }
    }

    func hasSequentialMessageAt(_ indexPath: IndexPath) -> Bool {
        let prevIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)

        guard
            let previousObject = itemAt(prevIndexPath)?.object.base as? MessageSectionModel,
            let object = itemAt(indexPath)?.object.base as? MessageSectionModel
        else {
            return false
        }

        let previousMessage = previousObject.message
        let message = object.message

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
