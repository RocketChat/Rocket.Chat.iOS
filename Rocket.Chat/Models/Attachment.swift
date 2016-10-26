//
//  Attachment.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 01/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class Attachment: BaseModel {
    var type: MessageType {
        get {
            if audioURL?.characters.count ?? 0 > 0 {
                return .audio
            }
            
            if videoURL?.characters.count ?? 0 > 0 {
                return .video
            }

            return .image
        }
    }
    
    dynamic var title = ""
    dynamic var titleLink = ""
    dynamic var titleLinkDownload = true
    
    dynamic var imageURL: String? = nil
    dynamic var imageType: String? = nil
    dynamic var imageSize = 0
    
    dynamic var audioURL: String? = nil
    dynamic var audioType: String? = nil
    dynamic var audioSize = 0
    
    dynamic var videoURL: String? = nil
    dynamic var videoType: String? = nil
    dynamic var videoSize = 0
    var videoThumbPath: URL? {
        get {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documents = path[0]
            return documents.appendingPathComponent("\(identifier ?? "temp").png")
        }
    }
    

    // MARK: ModelMapping

    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = String.random(30)
        }
        
        if let title = dict["title"].string {
            self.title = title
        }
        
        if let titleLink = dict["title_link"].string {
            self.titleLink = titleLink
        }
        
        self.titleLinkDownload = dict["title_link_download"].bool ?? true
        
        self.imageURL = encode(url: dict["image_url"].string)
        self.imageType = dict["image_type"].string
        self.imageSize = dict["image_size"].int ?? 0
        
        self.audioURL = encode(url: dict["audio_url"].string)
        self.audioType = dict["audio_type"].string
        self.audioSize = dict["audio_size"].int ?? 0
        
        self.videoURL = encode(url: dict["video_url"].string)
        self.videoType = dict["video_type"].string
        self.videoSize = dict["video_size"].int ?? 0
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
    
    override class func ignoredProperties() -> [String] {
        return ["videoThumb"]
    }
}

extension Attachment {
    
    fileprivate static func fullURLWith(_ path: String?) -> URL? {
        guard let path = path else { return nil }
        guard let auth = AuthManager.isAuthenticated() else { return nil }
        guard let userId = auth.userId else { return nil }
        guard let token = auth.token else { return nil }
        guard let siteURL = auth.settings?.siteURL else { return nil }
        var urlString = "\(siteURL)\(path)?rc_uid=\(userId)&rc_token=\(token)"
        urlString = urlString.replacingOccurrences(of: "//", with: "/")
        return URL(string: urlString)
    }
    
    func fullVideoURL() -> URL? {
        return Attachment.fullURLWith(videoURL)
    }
    
    func fullImageURL() -> URL? {
        return Attachment.fullURLWith(imageURL)
    }
    
}
