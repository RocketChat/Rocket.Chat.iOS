//
//  SEComposeTextCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SEComposeTextCell: UICollectionViewCell, SECell {
    @IBOutlet weak var textView: UITextView!

    var cellModel = SEComposeTextCellModel(text: "") {
        didSet {
            textView.text = cellModel.text
        }
    }
}
