//
//  UnmanagedMessage.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 19/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct UnmanagedMessage: UnmanagedObject, Equatable {
    typealias Object = Message
    var identifier: String
    var managedObject: Message
    var text: String
    var attachments: [Attachment]
    var user: UnmanagedUser?
}

extension UnmanagedMessage {
    init(_ message: Message) {
        managedObject = message
        identifier = message.identifier ?? "" // FA NOTE: We must check if we have a valid identifier before calling this init. If a message doesn't have an identifier we should consider it invalid.
        text = message.text
        user = message.user?.unmanaged
        attachments = message.attachments.compactMap({ attachment in
            if attachment.isFile && attachment.fullFileURL() != nil {
                return attachment
            }

            switch attachment.type {
            case .image where attachment.imageURL != nil:
                return attachment
            case .video where attachment.videoURL != nil:
                return attachment
            case .audio where attachment.audioURL != nil:
                return attachment
            case .textAttachment where attachment.fields.count > 0:
                return attachment
            default:
                break
            }

            return nil
        })
    }
}

extension UnmanagedMessage: Differentiable {
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String { return identifier }
}
