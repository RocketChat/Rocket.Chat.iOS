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

    var nameText: String {
        return file.name
    }

    var descriptionText: String {
        return file.description
    }

    init(contentIndex: Int, file: SEFile) {
        self.contentIndex = contentIndex
        self.file = file

        if file.mimetype == "image/jpeg" {
            image = UIImage(data: file.data) ?? #imageLiteral(resourceName: "icon_file")
        } else {
            image = #imageLiteral(resourceName: "icon_file")
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
