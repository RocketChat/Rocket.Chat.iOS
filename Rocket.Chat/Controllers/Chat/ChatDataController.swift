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

class ChatDataController {
    
    var data: [ChatData] = []
    
    func clear() {
        data = []
    }
    
    func itemAt(_ indexPath: IndexPath) -> ChatData? {
        for item in data {
            if item.indexPath?.row == indexPath.row && item.indexPath?.section == indexPath.section {
                return item
            }
        }
        
        return nil
    }
    
    func indexPathOf(_ identifier: String) -> IndexPath? {
        for item in data {
            if item.identifier == identifier {
                return item.indexPath
            }
        }
        
        return nil
    }
    
    func insert(_ items: [ChatData]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        var newItems: [ChatData] = []
        var lastObj = data.last
        
        for newObj in items {
            if let lastObj = lastObj {
                if lastObj.timestamp.day != newObj.timestamp.day ||
                    lastObj.timestamp.month != newObj.timestamp.month ||
                    lastObj.timestamp.year != newObj.timestamp.year {
                    
                    let date = newObj.timestamp
                    let calendar = NSCalendar(calendarIdentifier: .gregorian)!
                    let components = calendar.components([.day , .month, .year ], from: date)
                    let newDate = calendar.date(from: components)
                    let separator = ChatData(type: .daySeparator, timestamp: newDate!)!
                    newItems.append(separator)
                }
            }
        
            newItems.append(newObj)
            lastObj = newObj
        }
        
        for (idx, _) in newItems.enumerated() {
            indexPaths.append(IndexPath(row: idx, section: 0))
        }
        
        var normalizeds: [ChatData] = []
        data.append(contentsOf: newItems)
        data.sort(by: { $0.timestamp < $1.timestamp })
        
        for (idx, item) in data.enumerated() {
            var customItem = item
            customItem.indexPath = IndexPath(item: idx, section: 0)
            normalizeds.append(customItem)
        }
        
        data = normalizeds
        return indexPaths
    }
    
    func remove(_ items: [ChatData]) {
        
    }
    
}
