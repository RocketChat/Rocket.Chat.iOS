//
//  NotificationsCellProtocol.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 10.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol NotificationsCellProtocol where Self: UITableViewCell {
    var cellModel: NotificationSettingModel? { get set }
}
