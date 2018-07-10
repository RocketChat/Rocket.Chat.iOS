//
//  ChatMessageTextViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 01/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

protocol ChatMessageTextViewModelProtocol {
    var color: UIColor? { get }
    var title: String { get }
    var text: String { get }
    var thumbURL: URL? { get }
    var collapsed: Bool { get }
    var attachment: Attachment { get }
    var isFile: Bool { get }
    func toggleCollapse()
}

final class ChatMessageTextViewModel: ChatMessageTextViewModelProtocol {
    var color: UIColor? {
        guard let color = attachment.color else { return nil }
        return UIColor.normalizeColorFromString(string: color)
    }

    var title: String {
        guard !isFile else {
            return attachment.title
        }

        return "\(collapsed ? "▶" : "▼") \(attachment.title)"
    }

    var text: String {
        guard !isFile else {
            return localized("chat.message.open_file")
        }

        return attachment.text ?? ""
    }

    var thumbURL: URL? {
        return URL(string: attachment.thumbURL ?? "")
    }

    var collapsed: Bool {
        guard !isFile else {
            return false
        }

        return attachment.collapsed
    }

    var isFile: Bool {
        return attachment.isFile
    }

    let attachment: Attachment

    init(withAttachment attachment: Attachment) {
        self.attachment = attachment
    }

    func toggleCollapse() {
        guard !isFile else {
            return
        }

        Realm.executeOnMainThread({ _ in
            self.attachment.collapsed = !self.attachment.collapsed
        })
    }
}

final class ChatMessageAttachmentFieldViewModel: ChatMessageTextViewModelProtocol {
    var color: UIColor? {
        return  attachment.color != nil
            ? UIColor(hex: attachment.color)
            : UIColor.lightGray
    }

    var title: String {
        return attachmentField.title
    }

    var text: String {
        return attachmentField.value
    }

    var thumbURL: URL? {
        return nil
    }

    var collapsed: Bool {
        return attachment.collapsed
    }

    var isFile: Bool {
        return false
    }

    let attachment: Attachment
    let attachmentField: AttachmentField

    init(withAttachment attachment: Attachment, andAttachmentField attachmentField: AttachmentField) {
        self.attachment = attachment
        self.attachmentField = attachmentField
    }

    func toggleCollapse() {
        Realm.executeOnMainThread({ _ in
            self.attachment.collapsed = !self.attachment.collapsed
        })
    }
}
