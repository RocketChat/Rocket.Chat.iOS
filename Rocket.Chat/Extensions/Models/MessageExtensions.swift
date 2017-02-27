//
//  MessageExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension Message {

    func textNormalized() -> NSAttributedString {
        switch type {
            case .roomNameChanged:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.room_name_changed"),
                    text,
                    self.user?.username ?? ""
                ))

            case .userAdded:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.user_added_by"),
                    text,
                    self.user?.username ?? ""
                ))

            case .userRemoved:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.user_removed_by"),
                    text,
                    self.user?.username ?? ""
                ))

            case .userJoined:
                return grayItalicText(localizedString("chat.message.type.user_joined"))

            case .userLeft:
                return grayItalicText(localizedString("chat.message.type.user_left"))

            case .userMuted:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.user_muted"),
                    text,
                    self.user?.username ?? ""
                ))

            case .userUnmuted:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.user_unmuted"),
                    text,
                    self.user?.username ?? ""
                ))

            case .welcome:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.welcome"),
                    text
                ))

            case .messageRemoved:
                return grayItalicText(localizedString("chat.message.type.message_removed"))

            case .subscriptionRoleAdded:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.subscription_role_added"),
                    text,
                    role,
                    self.user?.username ?? ""
                ))

            case .subscriptionRoleRemoved:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.subscription_role_removed"),
                    text,
                    role,
                    self.user?.username ?? ""
                ))

            case .roomArchived:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.room_archived"),
                    text
                ))

            case .roomUnarchived:
                return grayItalicText(String(
                    format: localizedString("chat.message.type.room_unarchived"),
                    text
                ))

            default: break
        }

        return defaultMessageText(Emojione.transform(string: text))
    }

    fileprivate func defaultMessageText(_ string: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: string)
        mutableString.addAttributes([
            NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.darkGray
        ], range: NSRange(location: 0, length: string.characters.count))
        return mutableString
    }

    fileprivate func grayItalicText(_ string: String) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(string: string)
        mutableString.addAttributes([
            NSFontAttributeName: UIFont.italicSystemFont(ofSize: 14),
            NSForegroundColorAttributeName: UIColor.lightGray
        ], range: NSRange(location: 0, length: string.characters.count))
        return mutableString
    }

}
