//
//  MD5Hash.swift
//  RocketChat
//
//  Created by Luís Machado on 18/12/2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

func MD5(string: String) -> Data {
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    _ = digestData.withUnsafeMutableBytes {digestBytes in
        messageData.withUnsafeBytes {messageBytes in
            CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
        }
    }
    return digestData
}
