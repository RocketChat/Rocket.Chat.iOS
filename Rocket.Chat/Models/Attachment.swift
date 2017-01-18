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

        return .image
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
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = path[0]
        return documents.appendingPathComponent("\(identifier ?? "temp").png")
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
