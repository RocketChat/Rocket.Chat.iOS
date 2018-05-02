//
//  File.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class File: BaseModel {
    @objc dynamic var name = ""
    @objc dynamic var rid = ""
    @objc dynamic var size: Double = 0
    @objc dynamic var type = ""
    @objc dynamic var fileDescription = ""
    @objc dynamic var store = ""
    @objc dynamic var isComplete = false
    @objc dynamic var isUploading = false
    @objc dynamic var fileExtension = ""
    @objc dynamic var progress: Int = 0
    @objc dynamic var user: User?
    @objc dynamic var uploadedAt: Date?
    @objc dynamic var url = ""
}

extension File {
    var username: String {
        return user?.username ?? ""
    }

    var isImage: Bool {
        let imageTypes = ["gif", "jpg", "png", "jpeg", "image"]
        return imageTypes.compactMap { type.range(of: $0, options: .caseInsensitive) != nil ? true : nil }.first ?? false
    }

    var isVideo: Bool {
        let videoTypes = ["mp4", "mov", "video", "flv"]
        return videoTypes.compactMap { type.range(of: $0, options: .caseInsensitive) != nil ? true : nil }.first ?? false
    }

    var isAudio: Bool {
        let audioTypes = ["mp3", "wav", "3gp", "audio"]
        return audioTypes.compactMap { type.range(of: $0, options: .caseInsensitive) != nil ? true : nil }.first ?? false
    }

    var isDocument: Bool {
        let documentTypes = ["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "application"]
        return documentTypes.compactMap { type.range(of: $0, options: .caseInsensitive) != nil ? true : nil }.first ?? false
    }

    var videoThumbPath: URL? {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documents = path[0]
        let thumbName = url.replacingOccurrences(of: "/", with: "\\")
        return documents.appendingPathComponent("\(thumbName).png")
    }

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
        return File.fullURLWith(url, auth: auth)
    }
}
