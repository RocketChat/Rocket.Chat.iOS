//
//  ChatMessageTextViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 01/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

final class ChatMessageTextViewModel {

    var color: UIColor {
        if let color = attachment.color {
            return UIColor.normalizeColorFromString(string: color)
        }

        return .lightGray
    }

    var title: String {
        return attachment.title
    }

    var text: String {
        if attachment.titleLinkDownload && attachment.titleLink.count > 0 {
            return localized("chat.message.open_file")
        }

        return attachment.text ?? ""
    }

    var thumbURL: URL? {
        return URL(string: attachment.thumbURL ?? "")
    }

    var collapsed: Bool {
        return attachment.collapsed
    }

    let attachment: Attachment

    init(withAttachment attachment: Attachment) {
        self.attachment = attachment
    }

    func toggleCollpase() {
        Realm.executeOnMainThread({ _ in
            self.attachment.collapsed = !self.attachment.collapsed
        })
    }
}
