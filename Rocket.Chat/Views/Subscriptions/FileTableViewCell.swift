//
//  FileTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage
import Nuke

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
        filePreview.layer.cornerRadius = 4
        filePreview.layer.borderWidth = 0.5
        filePreview.layer.borderColor = UIColor.lightGray.cgColor
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
            updateImage(withURL: fileURL)
            return
        }

        if file.isVideo {
            updateVideo(withURL: fileURL)
            return
        }

        if file.isAudio {
            updateAudio(withURL: fileURL)
            return
        }

        if file.isDocument {
            updateDocument(withURL: fileURL)
            return
        }
    }

    func updateImage(withURL url: URL) {
        let options = ImageLoadingOptions(
            failureImage: #imageLiteral(resourceName: "Resource Unavailable"),
            contentModes: .init(
                success: .scaleAspectFill,
                failure: .scaleAspectFit,
                placeholder: .scaleAspectFit
            )
        )

        ImageManager.loadImage(with: url, options: options, into: filePreview)
    }

    func updateVideo(withURL url: URL) {
        playOverlay.isHidden = false
        guard let thumbURL = file.videoThumbPath else { return }

        if let imageData = try? Data(contentsOf: thumbURL) {
            if let thumbnail = UIImage(data: imageData) {
                filePreview.image = thumbnail
                return
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
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
                DispatchQueue.main.async {
                    self.filePreview.image = nil
                }
            }
        }
    }

    func updateAudio(withURL url: URL) {
        accessoryType = .disclosureIndicator
        filePreview.contentMode = .scaleAspectFit
        filePreview.image = #imageLiteral(resourceName: "audio")
    }

    func updateDocument(withURL url: URL) {
        filePreview.contentMode = .scaleAspectFit
        filePreview.image = #imageLiteral(resourceName: "icon_file")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = ""
        username.text = ""
        uploadedAt.text = ""
        playOverlay.isHidden = true
        accessoryType = .none
        filePreview.contentMode = .scaleAspectFill
        filePreview.animatedImage = nil
        filePreview.image = nil
        Nuke.cancelRequest(for: filePreview)
    }
}
