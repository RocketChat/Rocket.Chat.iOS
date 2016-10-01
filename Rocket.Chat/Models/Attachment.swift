//
//  Attachment.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 01/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

enum AttachmentType {
    case image
    case audio
    case video
}

class Attachment: BaseModel {
    dynamic var email = ""
    dynamic var verified = false
}
