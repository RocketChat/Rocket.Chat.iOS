//
//  AuthDelegate.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

public protocol AuthDelegate: class {
    func didLogout()
}
