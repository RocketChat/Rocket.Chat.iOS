//
//  SEComposeFileCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeFileCell: UICollectionViewCell, SECell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!

    var cellModel = SEComposeFileCellModel.emptyState {
        didSet {
            imageView.image = cellModel.image

            nameTextField.text = cellModel.nameText
            nameTextField.placeholder = cellModel.namePlaceholder

            descriptionTextField.text = cellModel.descriptionText
            descriptionTextField.placeholder = cellModel.descriptionPlaceholder

            statusLabel.text = cellModel.statusText
        }
    }
}
