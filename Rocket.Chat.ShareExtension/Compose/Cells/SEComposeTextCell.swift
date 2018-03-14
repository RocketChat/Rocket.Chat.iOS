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

    var cellModel = SEComposeTextCellModel(contentIndex: 0, text: "") {
        didSet {
            textView.text = cellModel.text
            textView.delegate = self
        }
    }
}

extension SEComposeTextCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        cellModel.text = textView.text

        let content = SEContent(type: .text(textView.text))
        store.dispatch(.setContentValue(content, index: cellModel.contentIndex))
    }
}
