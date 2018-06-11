//
//  SubscriptionSortingCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionSortingCell: UITableViewCell {

    static let cellHeight = CGFloat(50)
    static let identifier = "CellSubscriptionSortingOption"

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!

    internal let defaultBackgroundColor = UIColor.white
    internal let selectedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.08)
    internal let highlightedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.14)

}

extension SubscriptionSortingCell {

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
