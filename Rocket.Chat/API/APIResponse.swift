//
//  APIResponse.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

enum APIResponse<T: APIResource> {
    case resource(T)
    case error(APIError)
}
