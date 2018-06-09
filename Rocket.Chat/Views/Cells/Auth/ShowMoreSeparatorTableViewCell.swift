//
//  ShowMoreSeparatorTableViewCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ShowMoreSeparatorTableViewCell: UITableViewCell {

    static let rowHeight: CGFloat = 76

    @IBOutlet weak var showMoreButton: UIButton!

    var showOrHideLoginServices: (() -> Void)?

    @IBAction func showMoreButtonDidPressed() {
        showOrHideLoginServices?()
    }

}
