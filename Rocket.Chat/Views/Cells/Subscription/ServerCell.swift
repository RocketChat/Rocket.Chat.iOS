//
//  ServerCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {

    static let identifier = "kServerCellIdentifier"

    @IBOutlet weak var imageViewServer: UIImageView!
    @IBOutlet weak var labelServerName: UILabel!
    @IBOutlet weak var labelServerDescription: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        imageViewServer.image = nil
        labelServerName.text = ""
        labelServerDescription.text = ""
    }

    var server: [String: String]? {
        didSet {
            guard let server = server else { return }

            labelServerName.text = server[ServerPersistKeys.serverName]

            if let serverURL = URL(string: server[ServerPersistKeys.serverURL] ?? "") {
                labelServerDescription.text = serverURL.host
            }

            if let imageURL = URL(string: server[ServerPersistKeys.serverIconURL] ?? "") {
                imageViewServer.sd_setImage(with: imageURL)
            }
        }
    }

}
