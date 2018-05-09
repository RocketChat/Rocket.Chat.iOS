//
//  APIError.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

typealias APIErrored = (APIError) -> Void

enum APIError: CustomStringConvertible {
    case version(available: Version, required: Version)
    case error(Error)
    case noData
    case malformedRequest
    case notSecured

    var description: String {
        switch self {
        case .error(let error):
            return error.localizedDescription
        default:
            return Mirror(reflecting: self).children.first?.label ?? "unknown"
        }
    }
}

extension NSError {
    static var sslErrors: [Int] {
        return [NSURLErrorSecureConnectionFailed, NSURLErrorServerCertificateUntrusted, NSURLErrorServerCertificateHasBadDate, NSURLErrorServerCertificateNotYetValid, NSURLErrorServerCertificateHasUnknownRoot]
    }
}
