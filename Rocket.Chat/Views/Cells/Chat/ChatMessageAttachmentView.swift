//
//  ChatMessageAttachmentView.swift
//  Rocket.Chat
//
//  Created by Luca Justin Zimmermann on 01/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

class ChatMessageAttachmentView: UIView {
    class var defaultHeight: CGFloat {
        return 0
    }

    static func heightFor(withText description: String?) -> CGFloat {
        guard let text = description, !text.isEmpty else {
            return self.defaultHeight
        }

        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)]
        )

        let labelWidth = UIScreen.main.bounds.size.width - 55
        let height = attributedString.heightForView(withWidth: labelWidth)
        return self.defaultHeight + (height ?? -1) + 1
    }
}
