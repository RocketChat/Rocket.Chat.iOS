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
    
    func insert(_ items: [ChatData]) {
        var normalizeds: [ChatData] = []
        data.append(contentsOf: items)
        data.sort(by: { $0.timestamp < $1.timestamp })
        
        for (idx, item) in data.enumerated() {
            var customItem = item
            customItem.indexPath = IndexPath(item: idx, section: 0)
            normalizeds.append(customItem)
        }
        
        data = normalizeds
    }
    
    func remove(_ items: [ChatData]) {
        
    }
    
}
