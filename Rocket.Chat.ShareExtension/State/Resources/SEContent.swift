//
//  SEContent.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEFile {
    let name: String
    let mimetype: String
    let data: Data
}

enum SEContentType {
    case text(String)
    case file(SEFile)
}

enum SEContentStatus {
    case notSent
    case sending
    case succeeded
    case errored(String)
}

struct SEContent {
    let type: SEContentType
    let status: SEContentStatus
}

extension SEContent {
    init(type: SEContentType) {
        self.type = type
        self.status = .notSent
    }

    func withStatus(_ status: SEContentStatus) -> SEContent {
        return SEContent(type: type, status: status)
    }
}
