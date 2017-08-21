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
    case sendingMessage
    case loader
}

struct ChatData {
    var identifier = String.random(10)
    var type: ChatDataType = .message
    var timestamp: Date
    var indexPath: IndexPath!

    // This is only used for messages
    var message: Message?

    // Initializers
    init?(type: ChatDataType, timestamp: Date) {
        self.type = type
        self.timestamp = timestamp
    }
}

final class ChatDataController {

    var data: [ChatData] = []

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

    func indexPathOf(_ identifier: String) -> IndexPath? {
        return data.filter { item in
            return item.identifier == identifier
        }.flatMap { item in
            item.indexPath
        }.first
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func insert(_ items: [ChatData]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        var newItems: [ChatData] = []
        var lastObj = data.last
        var identifiers: [String] = items.map { $0.identifier }

        func insertDaySeparator(from obj: ChatData) {
            guard let calendar = NSCalendar(calendarIdentifier: .gregorian) else { return }
            let date = obj.timestamp
            let components = calendar.components([.day, .month, .year], from: date)
            guard let newDate = calendar.date(from: components) else { return }
            guard let separator = ChatData(type: .daySeparator, timestamp: newDate) else { return }
            identifiers.append(separator.identifier)
            newItems.append(separator)
        }

        for newObj in items {
            if let lastObj = lastObj {
                if lastObj.type == .message && (
                    lastObj.timestamp.day != newObj.timestamp.day ||
                    lastObj.timestamp.month != newObj.timestamp.month ||
                    lastObj.timestamp.year != newObj.timestamp.year) {

                    // Check if already contains some separator with this data
                    // swiftlint:disable for_where
                    var insert = true
                    for obj in data.filter({ $0.type == .daySeparator }) {
                        if lastObj.timestamp.day == obj.timestamp.day &&
                           lastObj.timestamp.month == obj.timestamp.month &&
                           lastObj.timestamp.year == obj.timestamp.year {
                            insert = false
                        }
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

            for identifier in identifiers {
                if identifier == item.identifier {
                    indexPaths.append(indexPath)
                    break
                }
            }
        }

        data = normalizeds
        return indexPaths
    }

    func update(_ message: Message) -> Int {
        for index in data.indices {
            var obj = data[index]

            if obj.message?.identifier == message.identifier {
                obj.message = message
                return obj.indexPath.row
            }
        }

        return -1
    }
}
