//
//  ChatMessageVideoView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

protocol ChatMessageVideoViewProtocol: class {
    func openVideoFromCell(attachment: Attachment)
}

final class ChatMessageVideoView: ChatMessageAttachmentView {
    override static var defaultHeight: CGFloat {
        return 250
    }

    weak var delegate: ChatMessageVideoViewProtocol?
    var attachment: Attachment! {
        didSet {
            updateMessageInformation()
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var detailText: UILabel!
    @IBOutlet weak var detailTextIndicator: UILabel!
    @IBOutlet weak var detailTextHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewPreview: UIImageView! {
        didSet {
            imageViewPreview.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var buttonPlay: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    fileprivate func updateMessageInformation() {
        buttonPlay.isHidden = true
        activityIndicator.startAnimating()
        labelTitle.text = attachment.title
        detailText.text = attachment.descriptionText
        detailTextIndicator.isHidden = attachment.descriptionText?.isEmpty ?? true
        let fullHeight = ChatMessageVideoView.heightFor(withText: attachment.descriptionText)
        fullHeightConstraint.constant = fullHeight
        detailTextHeightConstraint.constant = fullHeight - ChatMessageVideoView.defaultHeight

        guard let videoURL = attachment.fullVideoURL() else { return }
        guard let thumbURL = attachment.videoThumbPath else { return }

        if let imageData = try? Data(contentsOf: thumbURL) {
            if let thumbnail = UIImage(data: imageData) {
                stopLoadingPreview(thumbnail)
                return
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMake(1, 1)

            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: imageRef)
                try UIImagePNGRepresentation(thumbnail)?.write(to: thumbURL, options: .atomic)

                DispatchQueue.main.async {
                    self.stopLoadingPreview(thumbnail)
                }
            } catch {
                self.stopLoadingPreview(nil)
            }
        }
    }

    fileprivate func stopLoadingPreview(_ thumbnail: UIImage?) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.imageViewPreview.image = thumbnail
            self.buttonPlay.isHidden = false
        }
    }

    @IBAction func buttonPlayDidPressed(_ sender: Any) {
        delegate?.openVideoFromCell(attachment: attachment)
    }
}
