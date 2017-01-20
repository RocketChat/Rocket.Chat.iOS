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
    dynamic var siteURL: String?

    // File upload
    dynamic var uploadStorageType: String?

    // Amazon S3 settings
    dynamic var AWSS3Bucket: String?
    dynamic var AWSS3BucketURL: String?
    dynamic var AWSS3ACL: String?
    dynamic var AWSS3AccessKey: String?
    dynamic var AWSS3SecretKey: String?
    dynamic var AWSS3CDN: String?
    dynamic var AWSS3Region: String?
}
