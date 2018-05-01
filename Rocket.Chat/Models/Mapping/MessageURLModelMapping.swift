//
//  MessageURLModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension MessageURL: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        guard let url = values["url"].string else { return }
        guard let meta = values["meta"].dictionary else { return }

        targetURL = url
        title = MessageURL.parseTitle(meta: meta)
        textDescription = MessageURL.parseDescription(meta: meta)
        imageURL = MessageURL.parseImageURL(meta: meta)
    }

    // MARK: Helpers

    fileprivate static func parseTitle(meta: [String: JSON]) -> String? {
        if let result = meta["ogTitle"]?.string { return result }
        if let result = meta["twitterTitle"]?.string { return result }
        if let result = meta["title"]?.string { return result }
        if let result = meta["pageTitle"]?.string { return result }
        return nil
    }

    fileprivate static func parseDescription(meta: [String: JSON]) -> String? {
        if let result = meta["ogDescription"]?.string { return result }
        if let result = meta["twitterDescription"]?.string { return result }
        if let result = meta["description"]?.string { return result }
        return nil
    }

    fileprivate static func parseImageURL(meta: [String: JSON]) -> String? {
        if let result = meta["ogImage"]?.string { return result }
        if let result = meta["twitterImageSrc"]?.string { return result }
        return nil
    }
}
