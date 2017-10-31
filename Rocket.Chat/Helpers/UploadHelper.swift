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

    /**
        This method will creates a FileUpload object
        based on a file Data.

        - parameters:
            - data: The file Data to be based on.
        - returns: FileUpload object, if content is valid.
     */
    static func file(for data: Data, name: String, mimeType: String) -> FileUpload {
        return FileUpload(
            name: name,
            size: sizeFor(data),
            type: mimeType,
            data: data
        )
    }

    /**
        This method will creates a FileUpload object
        based on a file URL.

        - parameters:
            - url: The file URL to be based on.
        - returns: FileUpload object, if URL is valid.
     */
    static func file(for url: URL) -> FileUpload? {
        guard let data = try? Data(contentsOf: url) else { return nil }

        return file(
            for: data,
            name: nameFor(url),
            mimeType: mimeTypeFor(url)
        )
    }

    /**
        This method returns the size of some Data object.

        - parameters:
          - data: The data object to be inspected.
        - returns: The size of the data
     */
    static func sizeFor(_ data: Data) -> Int {
        return (data as NSData).length
    }

    /**
        This method tries to generate a name for a file with
        an extension, based on the URL of it. For example:
        - foo/bar.jpg will return bar.jpg
        - foo/bar/baz.png will return baz.jpg
        - foo will return foo

        - parameters:
            - url: The URL of the file to be generated the name.
        - returns: Filename based on the URL.
     */
    static func nameFor(_ url: URL) -> String {
        return url.pathComponents.last ?? "Unknown.\(url.pathExtension)"
    }

    /**
        This method tries to return the correct mimetype of
        some file, based on the URL of it. For example:
        - foo/bar.jpg will return image/jpg
        - foo/bar/baz.pdf will return application/pdf
        - foo will return application/octet-stream
 
        - parameters:
            - url: The URL of the file to get the mimetype.
        - returns: the mimetype of the file.
     */
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
