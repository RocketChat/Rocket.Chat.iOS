//
//  RoomOpenRequest.swift
//  VitimMobile
//
//  Created by Andrey Rudenko on 20/02/2019.
//  Copyright © 2019 Vitim. All rights reserved.
//

import SwiftyJSON

private extension SubscriptionType {
  var path: String {
    switch self {
    case .channel:
      return "/api/v1/channels.open"
    case .group:
      return "/api/v1/groups.open"
    case .directMessage:
      return "/api/v1/im.open"
    }
  }
}

final class RoomOpenRequest: APIRequest {
  typealias APIResourceType = RoomOpenResource

  let requiredVersion = Version(0, 48, 0)

  let method: HTTPMethod = .post
  var path: String {
    return type.path
  }

  let rid: String
  let type: SubscriptionType

  init(rid: String, subscriptionType: SubscriptionType) {
    self.rid = rid
    self.type = subscriptionType
  }

  func body() -> Data? {
    let body = JSON(
      ["roomId": rid]
    )

    return body.rawString()?.data(using: .utf8)
  }
}

final class RoomOpenResource: APIResource {
  var success: Bool? {
    return raw?["success"].boolValue
  }

  var error: String? {
    return raw?["error"].stringValue
  }
}
