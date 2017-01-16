//
//  AttachmentModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

extension Attachment: ModelMappeable {
    func map(_ values: JSON) {
        if self.identifier == nil {
            self.identifier = String.random(30)
        }

        if let title = values["title"].string {
            self.title = title
        }

        if let titleLink = values["title_link"].string {
            self.titleLink = titleLink
        }

        self.titleLinkDownload = values["title_link_download"].bool ?? true

        self.imageURL = encode(url: values["image_url"].string)
        self.imageType = values["image_type"].string
        self.imageSize = values["image_size"].int ?? 0

        self.audioURL = encode(url: values["audio_url"].string)
        self.audioType = values["audio_type"].string
        self.audioSize = values["audio_size"].int ?? 0

        self.videoURL = encode(url: values["video_url"].string)
        self.videoType = values["video_type"].string
        self.videoSize = values["video_size"].int ?? 0
    }

    fileprivate func encode(url: String?) -> String? {
        guard let url = url else { return nil }

        let parts = url.components(separatedBy: "/")
        var encoded: [String] = []
        for part in parts {
            if let string = part.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                encoded.append(string)
            } else {
                encoded.append(part)
            }
        }

        return encoded.joined(separator: "/")
    }
}
