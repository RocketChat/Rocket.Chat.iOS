//
//  FileTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage
import FLAnimatedImage

class FileTableViewCell: UITableViewCell {

    static let identifier = String(describing: FileTableViewCell.self)

    @IBOutlet weak var filePreview: FLAnimatedImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var uploadedAt: UILabel!

    var file: File! {
        didSet {
            bindFileData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        filePreview.sd_setShowActivityIndicatorView(true)
        filePreview.sd_setIndicatorStyle(.gray)
    }

    func bindFileData() {
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
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        name.text = ""
        username.text = ""
        uploadedAt.text = ""
        filePreview.animatedImage = nil
        filePreview.image = nil
        filePreview.sd_cancelCurrentImageLoad()
        filePreview.sd_cancelCurrentAnimationImagesLoad()
    }
}
