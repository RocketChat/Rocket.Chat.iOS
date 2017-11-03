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
        if audioURL?.count ?? 0 > 0 {
            return .audio
        }

        if videoURL?.count ?? 0 > 0 {
            return .video
        }

        if imageURL?.count ?? 0 > 0 {
            return .image
        }

        return .textAttachment
    }

    @objc dynamic var collapsed: Bool = false
    @objc dynamic var text: String?
    @objc dynamic var thumbURL: String?
    @objc dynamic var color: String?

    @objc dynamic var title = ""
    @objc dynamic var titleLink = ""
    @objc dynamic var titleLinkDownload = true

    @objc dynamic var imageURL: String?
    @objc dynamic var imageType: String?
    @objc dynamic var imageSize = 0

    @objc dynamic var audioURL: String?
    @objc dynamic var audioType: String?
    @objc dynamic var audioSize = 0

    @objc dynamic var videoURL: String?
    @objc dynamic var videoType: String?
    @objc dynamic var videoSize = 0
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
        guard
            let path = path?.replacingOccurrences(of: "//", with: "/"),
            let pathPercentEncoded = NSString(string: path).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let auth = AuthManager.isAuthenticated(),
            let userId = auth.userId,
            let token = auth.token,
            let baseURL = auth.baseURL()
        else {
            return nil
        }

        let urlString = "\(baseURL)\(pathPercentEncoded)?rc_uid=\(userId)&rc_token=\(token)"

        return URL(string: urlString)
    }

    func fullFileURL() -> URL? {
        return Attachment.fullURLWith(titleLink)
    }

    func fullVideoURL() -> URL? {
        return Attachment.fullURLWith(videoURL)
    }

    func fullImageURL() -> URL? {
        guard let imageURL = imageURL else { return nil }
        if imageURL.contains("http://") || imageURL.contains("https://") {
            return URL(string: imageURL)
        }

        return Attachment.fullURLWith(imageURL)
    }

    func fullAudioURL() -> URL? {
        return Attachment.fullURLWith(audioURL)
    }

}
