//
//  AttachmentModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension AttachmentField: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        self.short = values["short"].boolValue
        self.title = values["title"].stringValue
        self.value = values["value"].stringValue
    }
}

extension Attachment: ModelMappeable {

    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = String.random(30)
        }

        if let authorName = values["author_name"].string {
            self.title = "@\(authorName)"
        }

        if let title = values["title"].string {
            self.title = title.removingNewLines()
        }

        if let titleLink = values["title_link"].string {
            self.titleLink = titleLink
        }

        self.collapsed = values["collapsed"].bool ?? false
        self.text = values["text"].string
        self.descriptionText = values["description"].string
        self.thumbURL = values["thumb_url"].string
        self.color = values["color"].string

        self.titleLinkDownload = values["title_link_download"].boolValue

        if let imageURL = values["image_url"].string {
            if imageURL.contains("https://") || imageURL.contains("http://") {
                self.imageURL = imageURL
            } else {
                self.imageURL = encode(url: imageURL)
            }
        }

        self.imageType = values["image_type"].string
        self.imageSize = values["image_size"].int ?? 0

        self.audioURL = encode(url: values["audio_url"].string)
        self.audioType = values["audio_type"].string
        self.audioSize = values["audio_size"].int ?? 0

        self.videoURL = encode(url: values["video_url"].string)
        self.videoType = values["video_type"].string
        self.videoSize = values["video_size"].int ?? 0

        // Mentions
        if let fields = values["fields"].array {
            self.fields.removeAll()

            for field in fields {
                let obj = AttachmentField()
                obj.map(field, realm: realm)
                self.fields.append(obj)
            }
        }
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
