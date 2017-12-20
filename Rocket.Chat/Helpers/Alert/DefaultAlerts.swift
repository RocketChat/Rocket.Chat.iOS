//
//  DefaultAlerts.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Alert {
    static let pushTokenError = Alert(key: "alert.push_token_error")
    static let uploadError = Alert(key: "alert.upload_error")
    static let loginError = Alert(key: "alert.login_error")
    static let registerError = Alert(key: "alert.register_error")
}
