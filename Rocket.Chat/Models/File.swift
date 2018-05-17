//
//  File.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class File: BaseModel {
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
        return type.range(of: "image", options: .caseInsensitive) != nil
    }

    var isGif: Bool {
        let gifTypes = ["gif"]
        return gifTypes.compactMap { type.range(of: $0, options: .caseInsensitive) != nil ? true : nil }.first ?? false
    }

    var isVideo: Bool {
        return type.range(of: "video", options: .caseInsensitive) != nil
    }

    var isAudio: Bool {
        return type.range(of: "audio", options: .caseInsensitive) != nil
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
