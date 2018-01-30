//
//  ChatMessageImageView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage
import FLAnimatedImage

protocol ChatMessageImageViewProtocol: class {
    func openImageFromCell(attachment: Attachment, thumbnail: FLAnimatedImageView)
}

final class ChatMessageImageView: UIView {
    static let defaultHeight = CGFloat(250)
    var isLoadable = true

    weak var delegate: ChatMessageImageViewProtocol?
    var attachment: Attachment! {
        didSet {
            if oldValue != nil && oldValue.identifier == attachment.identifier {
                Log.debug("attachment is cached")
                return
            }

            updateMessageInformation()
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var detailTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorImageView: UIActivityIndicatorView!
    @IBOutlet weak var imageView: FLAnimatedImageView! {
        didSet {
            imageView.layer.cornerRadius = 3
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 1
        }
    }

    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapView))
    }()

    private func getImage() -> URL? {
        guard let imageURL = attachment.fullImageURL() else {
            return nil
        }
        if imageURL.absoluteString.starts(with: "http://") {
            isLoadable = false
            labelTitle.text = attachment.title + " (" + localized("alert.insecure_image.title") + ")"
            imageView.contentMode = UIViewContentMode.center
            imageView.sd_setImage(with: nil, placeholderImage: UIImage(named: "Resource Unavailable"))
            return nil
        }
        labelTitle.text = attachment.title
        detailText.text = attachment.desc
        //TODO: Test stuff
        detailText.lineBreakMode = .byWordWrapping
        detailText.numberOfLines = 0
        detailText.textAlignment = .left
        let attributedString = NSAttributedString(string: attachment.desc ?? "")
        let labelWidth = detailText.bounds.size.width
        let labelHeight = attributedString.heightForView(withWidth: labelWidth)
        Log.debug("LABEL HEIGHT: " + String(describing: labelHeight))
        detailTextHeightConstraint.constant = ChatMessageImageView.defaultHeight + (labelHeight ?? 0)
        fullHeightConstraint.constant = ChatMessageImageView.defaultHeight + (labelHeight ?? 0)
        detailText.sizeToFit()
        return imageURL
    }

    static func heightFor(withText text: String?, width: CGFloat) -> CGFloat {
        let attributedString = NSMutableAttributedString(string: text ?? "")

        let fullWidth = width //UIScreen.main.bounds.size.width
        let height = attributedString.heightForView(withWidth: fullWidth - 55)
        return self.defaultHeight + (height ?? 0)
    }

    fileprivate func updateMessageInformation() {
        let containsGesture = gestureRecognizers?.contains(tapGesture) ?? false
        if !containsGesture {
            addGestureRecognizer(tapGesture)
        }

        guard let imageURL = getImage() else {
            return
        }

        activityIndicatorImageView.startAnimating()

        let options: SDWebImageOptions = [.retryFailed, .scaleDownLargeImages]
        imageView.sd_setImage(with: imageURL, placeholderImage: nil, options: options, completed: { [weak self] _, _, _, _ in
            self?.activityIndicatorImageView.stopAnimating()
        })
    }

    @objc func didTapView() {
        if isLoadable {
            delegate?.openImageFromCell(attachment: attachment, thumbnail: imageView)
        } else {
            guard let imageURL = attachment.fullImageURL() else {
                return
            }
            Ask(key: "alert.insecure_image", buttonB: localized("chat.message.open_browser"), handlerB: { _ in
                ChatViewController.shared?.openURL(url: imageURL)
            }).present()
        }
    }
}
