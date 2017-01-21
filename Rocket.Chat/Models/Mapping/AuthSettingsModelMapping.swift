//
//  AuthSettingsModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

extension AuthSettings: ModelMappeable {
    func map(_ values: JSON) {
        if self.identifier == nil {
            self.identifier = String.random()
        }

        self.siteURL = objectForKey(object: values, key: "Site_Url")?.string

        self.uploadStorageType = objectForKey(object: values, key: "FileUpload_Storage_Type")?.string

        self.AWSS3Bucket = objectForKey(object: values, key: "FileUpload_S3_Bucket")?.string
        self.AWSS3BucketURL = objectForKey(object: values, key: "FileUpload_S3_BucketURL")?.string
        self.AWSS3ACL = objectForKey(object: values, key: "FileUpload_S3_Acl")?.string
        self.AWSS3AccessKey = objectForKey(object: values, key: "FileUpload_S3_AWSAccessKeyId")?.string
        self.AWSS3SecretKey = objectForKey(object: values, key: "FileUpload_S3_AWSSecretAccessKey")?.string
        self.AWSS3CDN = objectForKey(object: values, key: "FileUpload_S3_CDN")?.string
        self.AWSS3Region = objectForKey(object: values, key: "FileUpload_S3_Region")?.string
    }

    fileprivate func objectForKey(object: JSON, key: String) -> JSON? {
        return object.array?.filter { obj in
            return obj["_id"].string == key
        }.first
    }
}
