//
//  FileModelMapping.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension File: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].stringValue
        }

        name = values["name"].stringValue
        rid = values["rid"].stringValue
        size = values["size"].double ?? 0
        type = values["type"].stringValue
        fileDescription = values["description"].stringValue
        store = values["store"].stringValue
        isComplete = values["complete"].bool ?? false
        isUploading = values["uploading"].bool ?? false
        fileExtension = values["extension"].stringValue
        progress = values["progress"].int ?? 0
        uploadedAt = Date.dateFromString(values["uploadedAt"].stringValue)
        url = values["path"].stringValue

        if let userIdentifier = values["user"]["_id"].string {
            if let realm = realm {
                if let user = realm.object(ofType: User.self, forPrimaryKey: userIdentifier as AnyObject) {
                    self.user = user
                } else {
                    let user = User()
                    user.map(values["user"], realm: realm)
                    self.user = user
                }
            }
        }
    }
}
