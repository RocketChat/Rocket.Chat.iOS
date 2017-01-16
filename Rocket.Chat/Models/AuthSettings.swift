//
//  AuthSettings.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 06/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

final class AuthSettings: BaseModel {
    override var mapping: BaseModelMapping { return AuthSettingsModelMapping() }

    // MARK: Fields
    dynamic var siteURL: String?
}
