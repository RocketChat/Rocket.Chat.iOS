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

    var data: [ChatData] = []
    var loadedAllMessages = false

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
        let prevItem = itemAt(prevIndexPath)
        let item = itemAt(indexPath)

        guard (item?.message?.type.sequential ?? false) &&
            (prevItem?.message?.type.sequential ?? false) &&
            (item?.message?.groupable ?? true) &&
            (prevItem?.message?.groupable ?? true) else {
                return false
        }

        let sameUser = item?.message?.user == prevItem?.message?.user

        // is the message recent?
        guard let date = item?.message?.createdAt,
              let prevDate = prevItem?.message?.createdAt else {
            return false
        }

        let timeLimit = Message.maximumTimeForSequence
        let recent = date.timeIntervalSince(prevDate) < timeLimit

        return sameUser && recent
    }

    func indexPathOf(_ identifier: String) -> IndexPath? {
        return data.filter { item in
            return item.identifier == identifier
        }.flatMap { item in
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
                    where firstMessage.timestamp.day == obj.timestamp.day &&
                        firstMessage.timestamp.month == obj.timestamp.month &&
                        firstMessage.timestamp.year == obj.timestamp.year {
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

        for newObj in items {
            if let lastObj = lastObj {
                if lastObj.type == .message && (
                    lastObj.timestamp.day != newObj.timestamp.day ||
                    lastObj.timestamp.month != newObj.timestamp.month ||
                    lastObj.timestamp.year != newObj.timestamp.year) {

                    // Check if already contains some separator with this data
                    var insert = true
                    for obj in data.filter({ $0.type == .daySeparator })
                        where lastObj.timestamp.day == obj.timestamp.day &&
                            lastObj.timestamp.month == obj.timestamp.month &&
                            lastObj.timestamp.year == obj.timestamp.year {
                                insert = false
                    }

                    if insert {
                        insertDaySeparator(from: lastObj)
                    }
                }
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
                MessageTextCacheManager.shared.update(for: message)
                data[idx].message = message
                return obj.indexPath.row
        }

        return -1
    }

    func oldestMessage() -> Message? {
        for obj in data where obj.type == .message {
            return obj.message
        }

        return nil
    }

}
