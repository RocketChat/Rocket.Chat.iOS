//
//  FileTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage
import FLAnimatedImage

class FileTableViewCell: UITableViewCell {

    static let identifier = String(describing: FileTableViewCell.self)

    @IBOutlet weak var filePreview: FLAnimatedImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var uploadedAt: UILabel!
    @IBOutlet weak var playOverlay: UIImageView!

    var file: File! {
        didSet {
            updateFileData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        filePreview.sd_setShowActivityIndicatorView(true)
        filePreview.sd_setIndicatorStyle(.gray)
    }

    func updateFileData() {
        name.text = file.name
        username.text = "@\(file.username)"
        uploadedAt.text = file.uploadedAt?.formatted()

        guard let fileURL = file.fullFileURL() else {
            filePreview.animatedImage = nil
            filePreview.image = nil
            return
        }

        if file.isImage {
            filePreview.sd_setImage(with: fileURL) { (_, error, _, _) in
                guard error == nil else {
                    self.filePreview.contentMode = .scaleAspectFit
                    self.filePreview.image = #imageLiteral(resourceName: "Resource Unavailable")
                    return
                }
            }

            return
        }

        if file.isVideo {
            playOverlay.isHidden = false
            guard let thumbURL = file.videoThumbPath else { return }

            if let imageData = try? Data(contentsOf: thumbURL) {
                if let thumbnail = UIImage(data: imageData) {
                    filePreview.image = thumbnail
                    return
                }
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let asset = AVAsset(url: fileURL)
                let imageGenerator = AVAssetImageGenerator(asset: asset)
                imageGenerator.appliesPreferredTrackTransform = true
                let time = CMTimeMake(1, 1)

                do {
                    let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: imageRef)
                    try UIImagePNGRepresentation(thumbnail)?.write(to: thumbURL, options: .atomic)

                    DispatchQueue.main.async {
                        self.filePreview.image = thumbnail
                    }
                } catch {
                    self.filePreview.image = nil
                }
            }

            return
        }

        if file.isAudio {
            filePreview.contentMode = .scaleAspectFit
            filePreview.image = #imageLiteral(resourceName: "audio")
            return
        }

        if file.isDocument {
            filePreview.contentMode = .scaleAspectFit
            filePreview.image = #imageLiteral(resourceName: "icon_file")
            return
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = ""
        username.text = ""
        uploadedAt.text = ""
        playOverlay.isHidden = true
        filePreview.contentMode = .scaleAspectFill
        filePreview.animatedImage = nil
        filePreview.image = nil
        filePreview.sd_cancelCurrentImageLoad()
        filePreview.sd_cancelCurrentAnimationImagesLoad()
    }
}
