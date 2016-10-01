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
    var type: AttachmentType {
        get { return .image }
    }
    
    dynamic var title = ""
    dynamic var title_link = ""
    dynamic var title_link_download = true
    
    dynamic var image_url = ""
    dynamic var image_type = ""
    dynamic var image_size = ""
    dynamic var image_dimensions = ""
    
    dynamic var audio_url = ""
    dynamic var audio_type = ""
    dynamic var audio_size = ""
    
    dynamic var video_url = ""
    dynamic var video_type = ""
    dynamic var video_size = ""
}
