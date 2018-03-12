//
//  SEComposeFileCellModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct SEComposeFileCellModel: SEComposeCellModel {
    let image: UIImage
    let nameText: String
    let descriptionText: String

    init(file: SEFile) {
        if file.mimeType == "image/jpeg" {
            image = UIImage(data: file.data) ?? UIImage()
        } else {
            image = UIImage()
        }

        nameText = file.name
        descriptionText = ""
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
        return SEComposeFileCellModel(file: SEFile(name: "", mimeType: "", data: Data()))
    }
}
