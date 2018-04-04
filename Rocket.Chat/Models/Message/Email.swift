//
//  Email.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

final class Email: Object {
    @objc dynamic var email = ""
    @objc dynamic var verified = false
}
