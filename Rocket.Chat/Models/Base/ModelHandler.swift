//
//  ModelHandler.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

protocol ModelHandler {
    func add(_ values: JSON)
    func update(_ values: JSON)
    func remove(_ values: JSON)
}

extension ModelHandler where Self: BaseModel {
    static func handle(msg: ResponseMessage, primaryKey: String, values: JSON) {
        var object: Self!

        Realm.execute { (_) in
            if let newObject = try? Realm().object(ofType: Self.self, forPrimaryKey: primaryKey as AnyObject) {
                object = newObject
            }

            if object == nil {
                object = Self()
            }

            switch msg {
                case .Added:
                    object.add(values)
                    break
                case .Changed:
                    object.update(values)
                    break
                case .Removed:
                    object.remove(values)
                    break
                default:
                    object.update(values)
                    break
            }
        }
    }
}
