//
//  UploadHelper.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import MobileCoreServices

struct UploadHelper {

    static func file(for url: URL) -> FileUpload? {
        guard let data = try? Data(contentsOf: url) else { return nil }

        return FileUpload(
            name: nameFor(url),
            size: sizeFor(data),
            type: mimeTypeFor(url),
            data: data
        )
    }

    static func sizeFor(_ data: Data) -> Int {
        return (data as NSData).length
    }

    static func nameFor(_ url: URL) -> String {
        return url.pathComponents.last ?? "Unknown.\(url.pathExtension)"
    }

    static func mimeTypeFor(_ url: URL) -> String {
        let pathExtension = url.pathExtension

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }

        return "application/octet-stream"
    }

}
