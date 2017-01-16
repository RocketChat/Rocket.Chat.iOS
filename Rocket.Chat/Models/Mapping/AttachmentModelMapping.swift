//
//  AttachmentModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class AttachmentModelMapping: BaseModelMapping {
    typealias Model = Attachment

    // MARK: ModelMapping

    func map(_ instance: Attachment, values: JSON) {
        if instance.identifier == nil {
            instance.identifier = String.random(30)
        }

        if let title = values["title"].string {
            instance.title = title
        }

        if let titleLink = values["title_link"].string {
            instance.titleLink = titleLink
        }

        instance.titleLinkDownload = values["title_link_download"].bool ?? true

        instance.imageURL = encode(url: values["image_url"].string)
        instance.imageType = values["image_type"].string
        instance.imageSize = values["image_size"].int ?? 0

        instance.audioURL = encode(url: values["audio_url"].string)
        instance.audioType = values["audio_type"].string
        instance.audioSize = values["audio_size"].int ?? 0

        instance.videoURL = encode(url: values["video_url"].string)
        instance.videoType = values["video_type"].string
        instance.videoSize = values["video_size"].int ?? 0
    }

    // MARK: Helpers

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
