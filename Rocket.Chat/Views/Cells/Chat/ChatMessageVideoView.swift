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

protocol ChatMessageVideoViewProtocol {
    func openVideoFromCell(attachment: Attachment)
}

class ChatMessageVideoView: BaseView {
    static let defaultHeight = CGFloat(250)

    var delegate: ChatMessageVideoViewProtocol?
    var attachment: Attachment! {
        didSet {
            updateMessageInformation()
        }
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewPreview: UIImageView! {
        didSet {
            imageViewPreview.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var tapGesture: UITapGestureRecognizer?
    
    fileprivate func updateMessageInformation() {
        if let gesture = tapGesture {
            removeGestureRecognizer(gesture)
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture!)
        
        labelTitle.text = attachment.title
        
        guard let videoURL = attachment.fullVideoURL() else { return }
        activityIndicator.startAnimating()
    
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMake(1, 1)

            if let imageRef = try? imageGenerator.copyCGImage(at: time, actualTime: nil) {
                let thumbnail = UIImage(cgImage:imageRef)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.imageViewPreview.image = thumbnail
                }
            }
        }
    }
    
    func didTapView() {
        delegate?.openVideoFromCell(attachment: attachment)
    }
}
