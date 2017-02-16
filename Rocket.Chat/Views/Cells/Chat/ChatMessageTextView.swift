//
//  ChatMessageTextView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 2/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatMessageTextView: UIView {
    static let defaultHeight = CGFloat(50)
    fileprivate static let imageViewDefaultWidth = CGFloat(50)

    @IBOutlet weak var imageViewThumbWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel!

    var attachment: Attachment? {
        didSet {
            updateMessageInformation()
        }
    }

    fileprivate func updateMessageInformation() {
        guard let attachment = self.attachment else { return }

        labelTitle.text = attachment.title
        labelDescription.text = attachment.text

        if let imageURL = URL(string: attachment.thumbURL ?? "") {
            imageViewThumb.sd_setImage(with: imageURL, completed: { [weak self] _, error, _, _ in
                let width = error != nil ? 0 : ChatMessageTextView.imageViewDefaultWidth
                self?.imageViewThumbWidthConstraint.constant = width
                self?.layoutSubviews()
            })
        } else {
            imageViewThumbWidthConstraint.constant = 0
            layoutSubviews()
        }
    }
}
