//
//  SEContent.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct SEFile {
    var name: String
    var description: String
    let mimetype: String
    let data: Data
    let fileUrl: URL?

    static var empty: SEFile {
        return SEFile(name: "", description: "", mimetype: "", data: Data(), fileUrl: nil)
    }
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
