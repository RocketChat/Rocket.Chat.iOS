//
//  EmojiSearcherSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 1/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest
import Rocket_Chat

class EmojiSearcherSpec: XCTestCase {
    func testSearch() {
        let searcher = EmojiSearcher(emojis: [
            Emoji("smiling face with open mouth", ":smiley:", false, [], ["face", "mouth", "open", "smile"]),
            Emoji("smiling face with sunglasses", ":sunglasses:", false, [], ["bright", "cool", "eye", "eyewear", "face", "glasses", "smile", "sun", "sunglasses"]),
            Emoji("radioactive", ":radioactive:", false, [":radioactive_sign:"], ["radioactive", "sign"]),
            Emoji("thumbs up", ":thumbsup:", true, [":+1:", ":thumbup:"], ["+1", "hand", "thumb", "up"])
        ])

        let search0 = searcher.search(shortname: "e")
        XCTAssert(search0.count == 3)
        XCTAssert(search0[0].emoji.shortname == ":smiley:")
        XCTAssert(search0[1].emoji.shortname == ":sunglasses:")
        XCTAssert(search0[2].emoji.shortname == ":radioactive:")

        let search1 = searcher.search(shortname: "radioactive")
        XCTAssert(search1.count == 1)
        XCTAssert(search1[0].emoji.shortname == ":radioactive:")

        let search2 = searcher.search(shortname: "radioactive_sig")
        XCTAssert(search2.count == 1)
        XCTAssert(search2[0].emoji.shortname == ":radioactive:")
        XCTAssert(search2[0].suggestion == ":radioactive_sign:")

        let search3 = searcher.search(shortname: "+")
        XCTAssert(search3.count == 1)
        XCTAssert(search3[0].emoji.shortname == ":thumbsup:")
        XCTAssert(search3[0].suggestion == ":+1:")
    }
}
