//
//  ParseItemProviders.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

extension NSItemProvider {

    // MARK: Text

    func parseText() -> Bool {
        if hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { text, error in
                guard error == nil, let text = text as? String else { return }
                let content = store.state.content + [SEContent(type: .text(text))]
                store.dispatch(.setContent(content))
            }

            return true
        }

        return false
    }

    // MARK: URL

    func parseUrl() -> Bool {
        if hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { url, error in
                guard error == nil, let url = url as? URL else { return }
                let content = store.state.content + [SEContent(type: .text(url.absoluteString))]
                store.dispatch(.setContent(content))
            }

            return true
        }

        return false
    }

    // MARK: Image

    func parseImage() -> Bool {
        if hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { item, _ in
                let image: UIImage
                var name = "\(String.random(8)).jpeg"

                if let _image = item as? UIImage {
                    image = _image
                } else if let url = item as? URL, let data = try? Data(contentsOf: url), let _image = UIImage(data: data) {
                    image = _image
                    name = url.lastPathComponent
                } else {
                    image = UIImage()
                }

                if let data = UIImageJPEGRepresentation(image, 0.9) {
                    let file = SEFile(name: name, description: "", mimetype: "image/jpeg", data: data, previewImage: nil)
                    let content = store.state.content + [SEContent(type: .file(file))]
                    store.dispatch(.setContent(content))
                }
            })

            return true
        }

        return false
    }

    // MARK: Video

    func parseVideo() -> Bool {
        if hasItemConformingToTypeIdentifier(kUTTypeVideo as String) {
            loadItem(forTypeIdentifier: kUTTypeVideo as String, options: nil, completionHandler: { item, _ in
                var _data = item as? Data
                var name = "\(String.random(8)).mp4"
                var image: UIImage?

                if let url = item as? URL {
                    _data = try? Data(contentsOf: url)
                    name = url.lastPathComponent
                    image = firstFrame(videoURL: url)
                }

                guard let data = _data else { return }

                let file = SEFile(name: name, description: "", mimetype: "video/mp4", data: data, previewImage: image)
                let content = store.state.content + [SEContent(type: .file(file))]
                store.dispatch(.setContent(content))
            })

            return true
        }

        return false
    }

    // MARK: Any

    func parseAny() -> Bool {
        if hasItemConformingToTypeIdentifier(kUTTypeItem as String) {
            loadItem(forTypeIdentifier: kUTTypeItem as String, options: nil, completionHandler: { item, _ in
                let data: Data
                let mimetype: String
                var name = "\(String.random(8)).file"

                if let _data = item as? Data {
                    data = _data
                    mimetype = "application/octet-stream"
                } else if let url = item as? URL, let _data = try? Data(contentsOf: url) {
                    data = _data
                    name = url.lastPathComponent
                    mimetype = url.mimeType()
                } else {
                    return
                }

                let file = SEFile(name: name, description: "", mimetype: mimetype, data: data, previewImage: #imageLiteral(resourceName: "icon_file"))
                let content = store.state.content + [SEContent(type: .file(file))]
                store.dispatch(.setContent(content))
            })

            return true
        }

        return false
    }
}

func parseItemProviders(_ itemProviders: [NSItemProvider]) {
    itemProviders.forEach { itemProvider in
        if itemProvider.parseText() { return }
        if itemProvider.parseUrl() { return }
        if itemProvider.parseImage() { return }
        if itemProvider.parseVideo() { return }
        if itemProvider.parseAny() { return }
    }
}
