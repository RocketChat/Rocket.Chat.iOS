//
//  StringExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation


extension String {

    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.startIndex.advancedBy(Int(randomValue))])"
        }
        
        return randomString
    }
    
    func sha256() -> String {
        let digest = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))!

        if let data: NSData = self.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_SHA256(data.bytes, CC_LONG(data.length), UnsafeMutablePointer<UInt8>(digest.mutableBytes))
        }

        var string = "\(digest)".stringByReplacingOccurrencesOfString(" ", withString: "")
        string = string.stringByReplacingOccurrencesOfString("<", withString: "")
        string = string.stringByReplacingOccurrencesOfString(">", withString: "")
        return string
    }

}