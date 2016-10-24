//
//  MessageURL.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 17/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class MessageURL: BaseModel {
    dynamic var textDescription: String?
    dynamic var title: String?
    dynamic var targetURL: String?
    dynamic var imageURL: String?
    
    
    // MARK: ModelMapping
    
    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = String.random()
        }
        
        guard let url = dict["url"].string else { return }
        guard let meta = dict["meta"].dictionary else { return }

        targetURL = url
        title = MessageURL.parseTitle(meta: meta)
        textDescription = MessageURL.parseDescription(meta: meta)
        imageURL = MessageURL.parseImageURL(meta: meta)
    }
    
    func isValid() -> Bool {
        return title?.characters.count ?? 0 > 0 && textDescription?.characters.count ?? 0 > 0
    }
    
    
    // MARK: Parsers
    
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
