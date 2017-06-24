//
//  Email.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/18/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

/// Since a user can own multiple emails, a email can only be linked to one user. Represents a email instance.
public class Email: BaseModel {
    public dynamic var email = ""
    public dynamic var verified = false
}
