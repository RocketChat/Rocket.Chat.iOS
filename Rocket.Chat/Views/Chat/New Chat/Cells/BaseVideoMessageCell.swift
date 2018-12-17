//
//  BaseVideoMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 15/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation

class BaseVideoMessageCell: BaseMessageCell {
    var widthConstriant: NSLayoutConstraint!
    var loading = false

    func setupWidthConstraint() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstriant = contentView.widthAnchor.constraint(equalToConstant: messageWidth)
        widthConstriant.isActive = true
    }

    func updateLoadingState(with buttonPlayer: UIButton, and activityIndicatorView: UIActivityIndicatorView) {
        if loading {
            buttonPlayer.isHidden = true
            activityIndicatorView.startAnimating()
        } else {
            buttonPlayer.isHidden = false
            activityIndicatorView.stopAnimating()
        }
    }

    func updateVideo(with imageView: UIImageView) {
        guard
            let viewModel = viewModel?.base as? VideoMessageChatItem,
            let thumbURL = viewModel.videoThumbPath,
            let videoURL = viewModel.videoURL
        else {
            return
        }

        if let imageData = try? Data(contentsOf: thumbURL) {
            if let thumbnail = UIImage(data: imageData) {
                imageView.image = thumbnail
                loading = false
                return
            }
        }

        loading = true

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 1)

            do {
                let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: imageRef)
                try thumbnail.pngData()?.write(to: thumbURL, options: .atomic)

                DispatchQueue.main.async { [weak self] in
                    imageView.image = thumbnail
                    self?.loading = false
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.loading = false
                }
            }
        }
    }
}
