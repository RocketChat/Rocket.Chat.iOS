//
//  ReadReceiptsRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

final class ReadReceiptsRequest: APIRequest {
    typealias APIResourceType = ReadReceiptsResource

    let requiredVersion = Version(0, 63, 0)

    var path: String = "/api/v1/chat.getMessageReadReceipts"

    var query: String? {
        return "messageId=\(messageId)"
    }

    let messageId: String

    init(messageId: String) {
        self.messageId = messageId
    }
}

class ReadReceiptsResource: APIResource {
    var users: [User] {
        return raw?["receipts"].arrayValue.map { $0["user"] }.map {
            let user = User()
            user.map($0, realm: nil)
            return user
        } ?? []
    }
}
