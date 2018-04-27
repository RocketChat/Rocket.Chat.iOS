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

    func bindFileData() {
        name.text = file.name
        username.text = "@\(file.username)"
        uploadedAt.text = file.uploadedAt?.formatted()
    }
}
