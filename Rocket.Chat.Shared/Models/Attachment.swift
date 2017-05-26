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

    dynamic var collapsed: Bool = false
    dynamic var text: String?
    dynamic var thumbURL: String?
    dynamic var color: String?

    dynamic var title = ""
    dynamic var titleLink = ""
    dynamic var titleLinkDownload = true

    dynamic var imageURL: String?
    dynamic var imageType: String?
    dynamic var imageSize = 0

    dynamic var audioURL: String?
    dynamic var audioType: String?
    dynamic var audioSize = 0

    dynamic var videoURL: String?
    dynamic var videoType: String?
    dynamic var videoSize = 0
    var videoThumbPath: URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = path[0]
        return documents.appendingPathComponent("\(identifier ?? "temp").png")
    }

    override class func ignoredProperties() -> [String] {
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

    func fullVideoURL(inAuth auth: Auth) -> URL? {
        return Attachment.fullURLWith(videoURL, auth: auth)
    }

    func fullImageURL(inAuth auth: Auth) -> URL? {
        guard let imageURL = imageURL else { return nil }
        if imageURL.contains("http://") || imageURL.contains("https://") {
            return URL(string: imageURL)
        }

        return Attachment.fullURLWith(imageURL, auth: auth)
    }

}
