//
//  UnmanagedAttachment.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 11/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct UnmanagedField: Equatable {
    let short: Bool
    let title: String
    let value: String
}

struct UnmanagedAttachment: Equatable {
    var identifier: String
    var type: MessageType

    var isFile: Bool
    var collapsed: Bool
    var text: String?
    var descriptionText: String?
    var thumbURL: String?
    var color: String?

    var title: String
    var titleLink: String
    var titleLinkDownload: Bool

    var imageURL: String?
    var imageType: String?
    var imageSize = 0

    var audioURL: String?
    var audioType: String?
    var audioSize = 0

    var videoURL: String?
    var videoType: String?
    var videoSize = 0

    var fields: [UnmanagedField]

    // Processed Properties
    var fullFileURL: URL?
    var fullVideoURL: URL?
    var fullImageURL: URL?
    var fullAudioURL: URL?
    var videoThumbPath: URL?
}

extension UnmanagedAttachment {

    init?(_ attachment: Attachment) {
        guard let attachmentIdentifier = attachment.identifier else {
            return nil
        }

        identifier = attachmentIdentifier
        type = attachment.type
        isFile = attachment.isFile
        collapsed = attachment.collapsed
        text = attachment.text
        descriptionText = attachment.descriptionText
        thumbURL = attachment.thumbURL
        color = attachment.color
        title = attachment.title
        titleLink = attachment.titleLink
        titleLinkDownload = attachment.titleLinkDownload
        imageURL = attachment.imageURL
        imageType = attachment.imageType
        imageSize = attachment.imageSize
        audioURL = attachment.audioURL
        audioType = attachment.audioType
        audioSize = attachment.audioSize
        videoURL = attachment.videoURL
        videoType = attachment.videoType
        videoSize = attachment.videoSize

        fields = []
        for field in attachment.fields {
            fields.append(UnmanagedField(
                short: field.short,
                title: field.title,
                value: field.value
            ))
        }

        fullFileURL = attachment.fullFileURL(auth: nil)
        fullVideoURL = attachment.fullVideoURL(auth: nil)
        fullImageURL = attachment.fullImageURL(auth: nil)
        fullAudioURL = attachment.fullAudioURL(auth: nil)
        videoThumbPath = attachment.videoThumbPath
    }

}
