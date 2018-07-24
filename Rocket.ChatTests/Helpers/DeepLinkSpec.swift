//
//  DeepLinkSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 24/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class DeepLinkSpec: XCTestCase {
    let validDeeplinkURLs = [
        "https://go.rocket.chat/auth?host=open.rocket.chat&token=lkjadfalkdj2fe0f23f802f23080283hf08hsd0f08h&userId=initialuser",
        "https://go.rocket.chat/auth?host=open.rocket.chat",
        "https://go.rocket.chat/room?host=open.rocket.chat&rid=asdfasdf",
        "https://go.rocket.chat/mention?name=test",
        "https://go.rocket.chat/channel?name=general",
        "rocketchat://auth?host=open.rocket.chat&token=lkjadfalkdj2fe0f23f802f23080283hf08hsd0f08h&userId=initialuser",
        "rocketchat://auth?host=open.rocket.chat",
        "rocketchat://room?host=open.rocket.chat&rid=asdfasdf",
        "rocketchat://mention?name=test",
        "rocketchat://channel?name=general"
    ]

    func testSupportedDeepLinks() {
        let deeplinks = validDeeplinkURLs.compactMap({ URL(string: $0) }).compactMap { DeepLink(url: $0) }
        XCTAssertEqual(deeplinks.count, validDeeplinkURLs.count, "Failed to parse one or more supported deeplink URLs")
    }
}
