//
//  Attachment.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 01/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

enum AttachmentType {
    case image
    case audio
    case video
}

class Attachment: BaseModel {
    var type: AttachmentType {
        get {
            if audioURL?.characters.count ?? 0 > 0 {
                return .audio
            }
            
            if videoURL?.characters.count ?? 0 > 0 {
                return .video
            }

            return .image
        }
    }
    
    dynamic var title = ""
    dynamic var titleLink = ""
    dynamic var titleLinkDownload = true
    
    dynamic var imageURL: String? = nil
    dynamic var imageType: String? = nil
    dynamic var imageSize = 0
    
    dynamic var audioURL: String? = nil
    dynamic var audioType: String? = nil
    dynamic var audioSize = 0
    
    dynamic var videoURL: String? = nil
    dynamic var videoType: String? = nil
    dynamic var videoSize = 0
    

    // MARK: ModelMapping

    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = String.random(30)
        }
        
        if let title = dict["title"].string {
            self.title = title
        }
        
        if let titleLink = dict["title_link"].string {
            self.titleLink = titleLink
        }
        
        self.titleLinkDownload = dict["title_link_download"].bool ?? true
        
        self.imageURL = dict["image_url"].string
        self.imageType = dict["image_type"].string
        self.imageSize = dict["image_size"].int ?? 0
        
        self.audioURL = dict["audio_url"].string
        self.audioType = dict["audio_type"].string
        self.audioSize = dict["audio_size"].int ?? 0
        
        self.videoURL = dict["video_url"].string
        self.videoType = dict["video_type"].string
        self.videoSize = dict["video_size"].int ?? 0
    }
}
