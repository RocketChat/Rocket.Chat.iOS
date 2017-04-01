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
        return  attachment.color != nil
            ? UIColor(hex: attachment.color)
            : UIColor.lightGray
    }

    var title: String {
        return attachment.title
    }

    var text: String {
        return attachment.text ?? ""
    }

    var thumbURL: URL? {
        return URL(string: attachment.thumbURL ?? "")
    }

    var collapsed: Bool {
        return attachment.collapsed
    }

    private let attachment: Attachment

    init(withAttachment attachment: Attachment) {
        self.attachment = attachment
    }

    func toggleCollpase() {
        Realm.execute { _ in
            attachment.collapsed = !attachment.collapsed
        }
    }
}
