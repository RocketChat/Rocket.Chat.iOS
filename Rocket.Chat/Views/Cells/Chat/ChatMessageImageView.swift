//
//  ChatMessageImageView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

class ChatMessageImageView: BaseView {
    static let defaultHeight = CGFloat(150)

    var attachment: Attachment! {
        didSet {
            updateMessageInformation()
        }
    }
    
    @IBOutlet weak var activityIndicatorImageView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 4
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 0.5
        }
    }
    
    fileprivate func updateMessageInformation() {
        let imageURL = Attachment.fullImageURL(attachment)
        activityIndicatorImageView.startAnimating()
        imageView.sd_setImage(with: imageURL, completed: { [unowned self] (image, error, cacheType, imageURL) in
            self.activityIndicatorImageView.stopAnimating()
        })
    }
}
