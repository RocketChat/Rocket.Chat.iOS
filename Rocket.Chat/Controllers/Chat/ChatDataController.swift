//
//  ChatDataController.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

enum ChatDataType {
    case daySeparator
    case unreadSeparator
    case message
    case loader
    case header
}

struct ChatData {
    var identifier = String.random(10)
    var type: ChatDataType = .message
    var timestamp: Date
    var indexPath: IndexPath!

    // This is only used for messages
    var message: Message?

    // Initializers
    init(type: ChatDataType, timestamp: Date) {
        self.type = type
        self.timestamp = timestamp
    }
}

final class ChatDataController {
    var messagesUsernames: Set<String> = []
    var data: [ChatData] = [] {
        didSet {
            messagesUsernames.removeAll()
            messagesUsernames.formUnion(data.compactMap { $0.message?.user?.username })
        }
    }

    var loadedAllMessages = false
    lazy var lastSeen: Date = {
        return Date()
    }()
    var unreadSeparator = false
    var dismissUnreadSeparator = false

    @discardableResult
    func clear() -> [IndexPath] {
        var indexPaths: [IndexPath] = []

        for item in data {
            indexPaths.append(item.indexPath)
        }

        data = []
        return indexPaths
    }

    func itemAt(_ indexPath: IndexPath) -> ChatData? {
        return data.filter { item in
            return item.indexPath?.row == indexPath.row && item.indexPath?.section == indexPath.section
        }.first
    }

    func hasSequentialMessageAt(_ indexPath: IndexPath) -> Bool {
        let prevIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)

        guard
            let previousObject = itemAt(prevIndexPath),
            let message = itemAt(indexPath)?.message
        else {
            return false
        }

        var previousMessage = previousObject.message

        if previousMessage == nil {
            // Having an unread separator should not block the sequential messages
            if previousObject.type != .unreadSeparator {
                return false
            }

            // Here we get one object before the previous object to check
            // if the message can be sequential
            let prevIndexPath = IndexPath(row: prevIndexPath.row - 1, section: prevIndexPath.section)
            if let message = itemAt(prevIndexPath)?.message {
                previousMessage = message
            }
        }

        guard
            let prevMessage = previousMessage,
            message.type.sequential && prevMessage.type.sequential &&
            message.groupable && prevMessage.groupable
        else {
            return false
        }

        // don't group deleted messages
        if (message.markedForDeletion, prevMessage.markedForDeletion) != (false, false) {
            return false
        }

        // don't group failed messages
        if (message.failed, prevMessage.failed) != (false, false) {
            return false
        }

        // unwrap dates
        guard
            let date = message.createdAt,
            let prevDate = prevMessage.createdAt
        else {
            return false
        }

        let sameUser = message.user == prevMessage.user

        var timeLimit = AuthSettingsDefaults.messageGroupingPeriod
        if let settings = AuthSettingsManager.settings {
            timeLimit = settings.messageGroupingPeriod
        }

        let recent = Int(date.timeIntervalSince(prevDate)) < timeLimit
        return sameUser && recent
    }

    func indexPathOf(_ identifier: String) -> IndexPath? {
        return data.filter { item in
            return item.identifier == identifier
        }.compactMap { item in
            item.indexPath
        }.first
    }

    func indexPathOfMessage(identifier: String) -> IndexPath? {
        return data.filter { item in
            guard let messageIdentifier = item.message?.identifier else { return false }
            return messageIdentifier == identifier
        }.compactMap { item in
            item.indexPath
        }.first
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    @discardableResult
    func insert(_ items: [ChatData]) -> ([IndexPath], [IndexPath]) {
        var indexPaths: [IndexPath] = []
        var removedIndexPaths: [IndexPath] = []
        var newItems: [ChatData] = []
        var lastObj = data.last
        var identifiers: [String] = items.map { $0.identifier }

        func insertDaySeparator(from obj: ChatData) {
            guard let calendar = NSCalendar(calendarIdentifier: .gregorian) else { return }
            let date = obj.timestamp
            let components = calendar.components([.day, .month, .year], from: date)
            guard let newDate = calendar.date(from: components) else { return }
            let separator = ChatData(type: .daySeparator, timestamp: newDate)
            identifiers.append(separator.identifier)
            newItems.append(separator)
        }

        func insertUnreadSeparator() {
            let separator = ChatData(type: .unreadSeparator, timestamp: lastSeen)
            identifiers.append(separator.identifier)
            newItems.append(separator)
        }

        if dismissUnreadSeparator {
            for (idx, obj) in data.enumerated() where obj.type == .unreadSeparator {
                data.remove(at: idx)
                removedIndexPaths.append(obj.indexPath)
            }

            unreadSeparator = false
            dismissUnreadSeparator = false
        }

        func updateLastSeen() {
            if let mostRecentMessage = items.filter({$0.type == .message}).sorted(by: {$0.timestamp > $1.timestamp}).first {
                if mostRecentMessage.message?.user == AuthManager.currentUser() {
                    lastSeen = mostRecentMessage.timestamp
                } else if let secondMostRecentMessage = data.filter({$0.type == .message}).sorted(by: {$0.timestamp > $1.timestamp}).first,
                    mostRecentMessage.timestamp <= lastSeen && mostRecentMessage.timestamp > secondMostRecentMessage.timestamp {
                    lastSeen = secondMostRecentMessage.timestamp
                }
            }
        }

        updateLastSeen()

        if loadedAllMessages {
            if data.filter({ $0.type == .header }).count == 0 {
                let obj = ChatData(type: .header, timestamp: Date(timeIntervalSince1970: 0))
                newItems.append(obj)
                identifiers.append(obj.identifier)
            }

            let messages = data.filter({ $0.type == .message })
            let firstMessage = messages.sorted(by: { $0.timestamp < $1.timestamp }).first
            if let firstMessage = firstMessage {
                // Check if already contains some separator with this data
                var insert = true
                for obj in data.filter({ $0.type == .daySeparator })
                    where firstMessage.timestamp.sameDayAs(obj.timestamp) {
                        insert = false
                }

                if insert {
                    insertDaySeparator(from: firstMessage)
                }
            }
        }

        // Has loader?
        let loaders = data.filter({ $0.type == .loader })
        if loadedAllMessages {
            for (idx, obj) in loaders.enumerated() {
                data.remove(at: idx)
                removedIndexPaths.append(obj.indexPath)
            }
        } else {
            if loaders.count == 0 {
                let obj = ChatData(type: .loader, timestamp: Date(timeIntervalSince1970: 0))
                newItems.append(obj)
                identifiers.append(obj.identifier)
            }
        }

        func needsUnreadSeparator(_ obj: ChatData) -> Bool {
            if let currentUser = AuthManager.currentUser(), let objUser = obj.message?.user, currentUser != objUser {
                if obj.timestamp > lastSeen && !unreadSeparator {
                    unreadSeparator = true
                    return true
                }
            }

            return false
        }

        func needsDateSeparator(_ obj: ChatData) -> Bool {
            if obj.type != .message { return false }

            return data.filter({
                $0.type == .daySeparator && $0.timestamp.sameDayAs(obj.timestamp)
            }).count == 0 && newItems.filter({
                $0.type == .daySeparator && $0.timestamp.sameDayAs(obj.timestamp)
            }).count == 0
        }

        for newObj in items {
            if let lastObj = lastObj {
                if needsDateSeparator(lastObj) {
                    insertDaySeparator(from: lastObj)
                } else if needsDateSeparator(newObj) {
                    insertDaySeparator(from: newObj)
                }
            }

            if needsUnreadSeparator(newObj) {
                insertUnreadSeparator()
            }

            newItems.append(newObj)
            lastObj = newObj
        }

        data.append(contentsOf: newItems)
        data.sort(by: { $0.timestamp < $1.timestamp })

        var normalizeds: [ChatData] = []
        for (idx, item) in data.enumerated() {
            var customItem = item
            let indexPath = IndexPath(item: idx, section: 0)
            customItem.indexPath = indexPath
            normalizeds.append(customItem)

            for identifier in identifiers
                where identifier == item.identifier {
                    indexPaths.append(indexPath)
                    break
            }
        }

        data = normalizeds
        return (indexPaths, removedIndexPaths)
    }

    func update(_ message: Message) -> Int {
        for (idx, obj) in data.enumerated()
            where obj.message?.identifier == message.identifier {
                if obj.message?.updatedAt?.timeIntervalSince1970 == message.updatedAt?.timeIntervalSince1970 {
                   return -1
                }

                if let oldMessage = obj.message {
                    if !(oldMessage == message) {
                        MessageTextCacheManager.shared.update(for: message)
                    }
                }

                data[idx].message = message
                return obj.indexPath.row
        }

        return -1
    }

    @discardableResult
    func delete(msgId: String) -> Int? {
        if let index = data.index(where: { $0.message?.identifier == msgId }) {
            data[index].message?.markedForDeletion = true
            return index
        }

        return nil
    }

    func oldestMessage() -> Message? {
        for obj in data where obj.type == .message {
            return obj.message
        }

        return nil
    }
}
