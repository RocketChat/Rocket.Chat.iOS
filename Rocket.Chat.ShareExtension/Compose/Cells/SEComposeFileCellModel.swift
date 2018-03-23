//
//  SEComposeFileCellModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct SEComposeFileCellModel: SEComposeCellModel {
    let contentIndex: Int
    var file: SEFile

    let image: UIImage
    var detailText: String = ""
    var fileSizeText: String = ""

    var originalNameText: String = ""

    var nameText: String {
        return file.name
    }

    var descriptionText: String {
        return file.description
    }

    init(contentIndex: Int, file: SEFile) {
        self.originalNameText = file.name
        self.contentIndex = contentIndex
        self.file = file
        self.fileSizeText = "\(Double(file.data.count)/1000000)MB"

        if file.mimetype.contains("image/"), let image = UIImage(data: file.data) {
            self.image = image
            self.detailText = "\(Int(image.size.width))x\(Int(image.size.height))"
        } else if let url = file.fileUrl, let videoInfo = VideoInfo(videoURL: url) {
            self.image = videoInfo.thumbnail
            self.detailText = videoInfo.durationText
        } else {
            self.image = #imageLiteral(resourceName: "icon_file")
        }
    }

    var namePlaceholder: String {
        return localized("compose.file.name.placeholder")
    }

    var descriptionPlaceholder: String {
        return localized("compose.file.description.placeholder")
    }
}

// MARK: Empty State

extension SEComposeFileCellModel {
    static var emptyState: SEComposeFileCellModel {
        return SEComposeFileCellModel(contentIndex: 0, file: .empty)
    }
}
