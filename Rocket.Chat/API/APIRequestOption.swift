//
//  APIRequestOption.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum APIRequestOption: Hashable {
    case paginated(count: Int, offset: Int)
    case retryOnError(count: Int)
    case none

    var query: String? {
        switch self {
        case .paginated(let count, let offset):
            return "count=\(count)&offset=\(offset)"
        default:
            return nil
        }
    }
}

typealias APIRequestOptionSet = Set<APIRequestOption>

extension Set where Element == APIRequestOption {
    var retries: Int {
        for option in self {
            if case let .retryOnError(retries) = option {
                return retries
            }
        }

        return 0
    }

    func withRetries(_ retries: Int) -> APIRequestOptionSet {
        return Set(map {
            if case .retryOnError = $0 {
                return .retryOnError(count: retries)
            }

            return $0
        })
    }
}
