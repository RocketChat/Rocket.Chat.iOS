//
//  SettingModelMapping.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import RealmSwift

extension Setting: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        self.identifier = values["_id"].stringValue
        self.value = values["value"].stringValue
    }
}
