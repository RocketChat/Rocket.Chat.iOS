//
//  SEComposeFileCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import NotificationCenter

class SEComposeFileCell: UICollectionViewCell, SECell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(nameDidChange(_:)), name: .UITextFieldTextDidChange, object: nameTextField)
        }
    }
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var descriptionTextField: UITextField! {
        didSet {
            NotificationCenter.default.addObserver(self, selector: #selector(descriptionDidChange(_:)), name: .UITextFieldTextDidChange, object: descriptionTextField)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    var cellModel = SEComposeFileCellModel.emptyState {
        didSet {
            imageView.image = cellModel.image

            nameTextField.text = cellModel.nameText
            nameTextField.placeholder = cellModel.namePlaceholder

            descriptionTextField.text = cellModel.descriptionText
            descriptionTextField.placeholder = cellModel.descriptionPlaceholder
            durationLabel.text = cellModel.durationText
        }
    }

    @objc func nameDidChange(_ textField: UITextField) {
        cellModel.file.name = nameTextField.text ?? ""
        store.dispatch(.setContentValue(SEContent(type: .file(cellModel.file)), index: cellModel.contentIndex))
    }

    @objc func descriptionDidChange(_ textField: UITextField) {
        cellModel.file.description = descriptionTextField.text ?? ""
        store.dispatch(.setContentValue(SEContent(type: .file(cellModel.file)), index: cellModel.contentIndex))
    }
}
