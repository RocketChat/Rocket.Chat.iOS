//
//  ChatMessageImageView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

protocol ChatMessageImageViewProtocol: class {
    func openImageFromCell(attachment: Attachment, thumbnail: UIImageView)
}

class ChatMessageImageView: BaseView {
    static let defaultHeight = CGFloat(250)

    weak var delegate: ChatMessageImageViewProtocol?
    var attachment: Attachment! {
        didSet {
            updateMessageInformation()
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var activityIndicatorImageView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 3
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 1
        }
    }

    var tapGesture: UITapGestureRecognizer?

    fileprivate func updateMessageInformation() {
        if let gesture = tapGesture {
            removeGestureRecognizer(gesture)
        }

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture!)

        labelTitle.text = attachment.title

        let imageURL = attachment.fullImageURL()
        activityIndicatorImageView.startAnimating()
        imageView.sd_setImage(with: imageURL, completed: { [weak self] _, _, _, _ in
            self?.activityIndicatorImageView.stopAnimating()
        })
    }

    func didTapView() {
        delegate?.openImageFromCell(attachment: attachment, thumbnail: imageView)
    }
}
