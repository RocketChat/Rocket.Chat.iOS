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

/// A data structure represents an attachment
public class Attachment: BaseModel {
    public var type: MessageType {
        if audioURL?.characters.count ?? 0 > 0 {
            return .audio
        }

        if videoURL?.characters.count ?? 0 > 0 {
            return .video
        }

        if imageURL?.characters.count ?? 0 > 0 {
            return .image
        }

        return .textAttachment
    }

    public dynamic var collapsed: Bool = false
    public dynamic var text: String?
    public dynamic var thumbURL: String?
    public dynamic var color: String?

    public dynamic var title = ""
    public dynamic var titleLink = ""
    public dynamic var titleLinkDownload = true

    public dynamic var imageURL: String?
    public dynamic var imageType: String?
    public dynamic var imageSize = 0

    public dynamic var audioURL: String?
    public dynamic var audioType: String?
    public dynamic var audioSize = 0

    public dynamic var videoURL: String?
    public dynamic var videoType: String?
    public dynamic var videoSize = 0
    public var videoThumbPath: URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = path[0]
        return documents.appendingPathComponent("\(identifier ?? "temp").png")
    }

    public override class func ignoredProperties() -> [String] {
        return ["videoThumb"]
    }
}

extension Attachment {

    fileprivate static func fullURLWith(_ path: String?, auth: Auth) -> URL? {
        guard let path = path?.replacingOccurrences(of: "//", with: "/") else { return nil }
        guard let userId = auth.userId else { return nil }
        guard let token = auth.token else { return nil }
        guard let baseURL = auth.baseURL() else { return nil }
        let urlString = "\(baseURL)\(path)?rc_uid=\(userId)&rc_token=\(token)"
        return URL(string: urlString)
    }

    public func fullVideoURL(inAuth auth: Auth) -> URL? {
        return Attachment.fullURLWith(videoURL, auth: auth)
    }

    public func fullImageURL(inAuth auth: Auth) -> URL? {
        guard let imageURL = imageURL else { return nil }
        if imageURL.contains("http://") || imageURL.contains("https://") {
            return URL(string: imageURL)
        }

        return Attachment.fullURLWith(imageURL, auth: auth)
    }

}
