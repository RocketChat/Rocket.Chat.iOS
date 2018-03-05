//
//  NotificationsSwitchCell.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class NotificationsSwitchCell: UITableViewCell {
@IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftDescriptionLabel: UILabel!
    @IBOutlet weak var rightTitleLabel: UILabel!
    @IBOutlet weak var rightDescriptionLabel: UILabel!
    @IBOutlet weak var turnSwitch: UISwitch!
}
