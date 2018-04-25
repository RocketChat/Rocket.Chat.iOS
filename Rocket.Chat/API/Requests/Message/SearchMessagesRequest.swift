//
//  SearchMessagesRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 24/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

final class SearchMessagesRequest: APIRequest {
    typealias APIResourceType = SearchMessagesResource

    let requiredVersion = Version(0, 60, 0)
    let path = "/api/v1/chat.search"

    let roomId: String?
    var query: String?

    init(roomId: String, searchText: String) {
        self.roomId = roomId
        self.query = "roomId=\(roomId)&searchText=\(searchText)"
    }
}

final class SearchMessagesResource: APIResource {
    var messages: [Message]? {
        return raw?["messages"].arrayValue.map {
            let message = Message()
            message.map($0, realm: nil)
            return message
        }
    }

    var errorMessage: String? {
        return raw?["error"].string
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }
}
