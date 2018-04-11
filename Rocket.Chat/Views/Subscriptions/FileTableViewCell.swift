//
//  FileTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class FileTableViewCell: UITableViewCell {

    static let identifier = String(describing: FileTableViewCell.self)

    @IBOutlet weak var filePreview: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var uploadedAt: UILabel!

}
