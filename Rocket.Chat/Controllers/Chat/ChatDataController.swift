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
    var indexPath: IndexPath
    
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
    
    func insert(_ items: [ChatData]) {
        var normalizeds: [ChatData] = []
        let identifiers = items.map { $0.identifier }
        data.append(contentsOf: items)
        data.sort(by: { $0.timestamp > $1.timestamp })
        
        for (idx, item) in data.enumerated() {
            if let index = identifiers.index(of: item.identifier) {
                var item = items[index]
                item.indexPath = IndexPath(item: idx, section: 0)
                normalizeds.append(item)
            }
        }
        
        dump(items)
    }
    
    func remove(_ items: [ChatData]) {
        
    }
    
}
