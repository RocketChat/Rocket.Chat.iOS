//
//  NotificationView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 3/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    func displayNotification(title: String, body: String) {
        titleLabel.text = title
        bodyLabel.text = body
    }

}
