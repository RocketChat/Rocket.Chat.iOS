//
//  File.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class File: BaseModel {
    @objc dynamic var name = ""
    @objc dynamic var rid = ""
    @objc dynamic var size: Double = 0
    @objc dynamic var type = ""
    @objc dynamic var fileDescription = ""
    @objc dynamic var store = ""
    @objc dynamic var isComplete = false
    @objc dynamic var isUploading = false
    @objc dynamic var fileExtension = ""
    @objc dynamic var progress: Int = 0
    @objc dynamic var user: User?
    @objc dynamic var uploadedAt: Date?
    @objc dynamic var url = ""
}

extension File {
    var username: String {
        return user?.username ?? ""
    }
}
