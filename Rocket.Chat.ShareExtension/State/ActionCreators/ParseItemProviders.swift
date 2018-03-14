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

func parseItemProviders(_ itemProviders: [NSItemProvider]) {
    itemProviders.forEach { itemProvider in

        // MARK: Text / URL

        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            itemProvider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil) { text, error in
                guard error == nil, let text = text as? String else { return }
                let content = store.state.content + [SEContent(type: .text(text))]
                store.dispatch(.setContent(content))
            }

            return
        }

        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeURL as String) {
            itemProvider.loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { url, error in
                guard error == nil, let url = url as? URL else { return }
                let content = store.state.content + [SEContent(type: .text(url.absoluteString))]
                store.dispatch(.setContent(content))
            }

            return
        }

        // MARK: Image

        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
            itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { item, _ in
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
                    let file = SEFile(name: name, description: "", mimetype: "image/jpeg", data: data)
                    let content = store.state.content + [SEContent(type: .file(file))]
                    store.dispatch(.setContent(content))
                }
            })

            return
        }

        // MARK: Any

        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeItem as String) {
            itemProvider.loadItem(forTypeIdentifier: kUTTypeItem as String, options: nil, completionHandler: { item, _ in
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

                let file = SEFile(name: name, description: "", mimetype: mimetype, data: data)
                let content = store.state.content + [SEContent(type: .file(file))]
                store.dispatch(.setContent(content))
            })

            return
        }
    }
}
