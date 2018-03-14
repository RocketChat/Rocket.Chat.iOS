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

class AttachmentField: BaseModel {
    @objc dynamic var short: Bool = false
    @objc dynamic var title: String = ""
    @objc dynamic var value: String = ""
}

class Attachment: BaseModel {
    var type: MessageType {
        if !(audioURL?.isEmpty ?? true) {
            return .audio
        }

        if !(videoURL?.isEmpty ?? true) {
            return .video
        }

        if !(imageURL?.isEmpty ?? true) {
            return .image
        }

        return .textAttachment
    }

    var isFile: Bool {
        return titleLinkDownload && !titleLink.isEmpty
    }

    @objc dynamic var collapsed: Bool = false
    @objc dynamic var text: String?
    @objc dynamic var descriptionText: String?
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
        let thumbName = videoURL?.replacingOccurrences(of: "/", with: "\\") ?? "temp"
        return documents.appendingPathComponent("\(thumbName).png")
    }

    var fields = List<AttachmentField>()

    override class func ignoredProperties() -> [String] {
        return ["videoThumb"]
    }
}

extension Attachment {

    fileprivate static func fullURLWith(_ path: String?, auth: Auth? = nil) -> URL? {
        guard let path = path else { return nil }

        if path.contains("http://") || path.contains("https://") {
            return URL(string: path)
        }

        let pathClean = path.replacingOccurrences(of: "//", with: "/")

        guard
            let pathPercentEncoded = NSString(string: pathClean).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let auth = auth ?? AuthManager.isAuthenticated(),
            let userId = auth.userId,
            let token = auth.token,
            let baseURL = auth.baseURL()
        else {
            return nil
        }

        let urlString = "\(baseURL)\(pathPercentEncoded)?rc_uid=\(userId)&rc_token=\(token)"
        return URL(string: urlString)
    }

    func fullFileURL(auth: Auth? = nil) -> URL? {
        return Attachment.fullURLWith(titleLink, auth: auth)
    }

    func fullVideoURL(auth: Auth? = nil) -> URL? {
        return Attachment.fullURLWith(videoURL, auth: auth)
    }

    func fullImageURL(auth: Auth? = nil) -> URL? {
        return Attachment.fullURLWith(imageURL, auth: auth)
    }

    func fullAudioURL(auth: Auth? = nil) -> URL? {
        return Attachment.fullURLWith(audioURL, auth: auth)
    }

}
