//
//  StringExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

func localized(_ string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

extension String {

    static func random(_ length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.characters.index(base.startIndex, offsetBy: Int(randomValue))])"
        }

        return randomString
    }

    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }

        return ""
    }

    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }

        return hexString
    }

    func ranges(of string: String) -> [Range<Index>] {
        var ranges = [Range<Index>]()

        let pCount = string.characters.count
        let strCount = self.characters.count

        if strCount < pCount { return [] }

        for i in 0...(strCount-pCount) {

            let from = index(self.startIndex, offsetBy: i)

            if let to = index(from, offsetBy: pCount, limitedBy: self.endIndex) {

                if string == self[from..<to] {
                    ranges.append(from..<to)
                }
            }
        }

        return ranges
    }

    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
