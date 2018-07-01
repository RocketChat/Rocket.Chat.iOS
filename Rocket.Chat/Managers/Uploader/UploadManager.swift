//
//  UploadManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 19/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias UploadProgressBlock = (Int) -> Void
public typealias UploadCompletionBlock = (SocketResponse?, Bool) -> Void

struct FileUpload {
    var name: String
    var size: Int
    var type: String
    var data: Data
}

