//
//  Setting.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

class Setting: BaseModel {
    @objc dynamic var value: String = ""
}
