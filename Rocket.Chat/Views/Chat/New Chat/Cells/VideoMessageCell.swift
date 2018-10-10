//
//  VideoMessageCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation
import RocketChatViewController

final class VideoMessageCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: VideoMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = VideoMessageCell.instantiateFromNib() else {
            return VideoMessageCell()
        }

        return cell
    }()

    var adjustedHorizontalInsets: CGFloat = 0
    var viewModel: AnyChatItem?

    var loading = false {
        didSet {
            updateLoadingState()
        }
    }

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var imageViewThumb: UIImageView! {
        didSet {
            imageViewThumb.layer.cornerRadius = 4
            imageViewThumb.clipsToBounds = true
        }
    }

    @IBOutlet weak var buttonPlayer: UIButton!
    @IBOutlet weak var labelDescription: UILabel!

    func configure() {
        guard let viewModel = viewModel?.base as? VideoMessageChatItem else {
            return
        }

        labelDescription.text = viewModel.descriptionText
        updateVideo(viewModel: viewModel)
    }

    func updateLoadingState() {
        if loading {
            buttonPlayer.isHidden = true
            activityIndicatorView.startAnimating()
        } else {
            buttonPlayer.isHidden = false
            activityIndicatorView.stopAnimating()
        }
    }

    func updateVideo(viewModel: VideoMessageChatItem) {
        guard
            let thumbURL = viewModel.videoThumbPath,
            let videoURL = viewModel.videoURL
        else {
            return
        }

        if let imageData = try? Data(contentsOf: thumbURL) {
            if let thumbnail = UIImage(data: imageData) {
                imageViewThumb.image = thumbnail
                loading = false
                return
            }
        }

        loading = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTimeMake(value: 1, timescale: 1)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                do {
                    let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: imageRef)
                    try thumbnail.pngData()?.write(to: thumbURL, options: .atomic)

                    self.imageViewThumb.image = thumbnail
                    self.loading = false
                } catch {
                    self.loading = false
                }
            }
        }
    }

    @IBAction func buttonPlayDidPressed(_ sender: Any) {
        // delegate?.openVideoFromCell(attachment: attachment)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageViewThumb.image = nil
        loading = false
    }
}
