//
//  noDetailsTableViewCell.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 8/18/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class NoDetailsTableViewCell: UITableViewCell {

    @IBOutlet var hiddenTimeStamp: UILabel!
    @IBOutlet var noDetailsMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
