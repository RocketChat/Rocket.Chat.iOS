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

    @IBOutlet weak var imageViewServer: UIImageView! {
        didSet {
            imageViewServer.layer.masksToBounds = true
            imageViewServer.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var labelServerName: UILabel!
    @IBOutlet weak var labelServerDescription: UILabel!

    internal let defaultBackgroundColor = UIColor.clear
    internal let selectedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.18)
    internal let highlightedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.27)

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

extension ServerCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        let transition = {
            switch selected {
            case true:
                self.backgroundColor = self.selectedBackgroundColor
            case false:
                self.backgroundColor = self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let transition = {
            switch highlighted {
            case true:
                self.backgroundColor = self.highlightedBackgroundColor
            case false:
                self.backgroundColor = self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }

}
