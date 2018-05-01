//
//  EmojioneSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 2/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest
@testable import Rocket_Chat

class EmojioneSpec: XCTestCase {

    func testEmojioneTransform() {
        let string = """
        :family_wwgb: :smiley:

        ```
        :apple:
        :apple: test
        ```
        Meow <- :cat:
        :dog: -> Woof

        :family_mwg: :+1_tone1:

        ```
        Meow <- :cat:
        :dog: -> Woof

        ```
        Hello :earth_americas: !
        """

        XCTAssert(Emojione.transform(string: string) == """
            👩‍👩‍👧‍👦 😃

            ```
            :apple:
            :apple: test
            ```
            Meow <- 🐱
            🐶 -> Woof

            👨‍👩‍👧 👍🏻

            ```
            Meow <- :cat:
            :dog: -> Woof

            ```
            Hello 🌎 !
            """
        )

        let string2 = ":aa:a:aa:smiley:a"
        XCTAssert(Emojione.transform(string: string2) == ":aa🅰️aa😃a")
    }

    func testCatastrophicBacktrackingOfRegex() {
        let string = ":supercalifragilisticexpialidocious,:pneumonoultramicroscopicsilicovolcanoconiosis:smiley:a"
        let expect = expectation(description: "Regex parsing is expected to finish within a minimal amount of time")
        DispatchQueue.global(qos: .background).async {
            XCTAssert(Emojione.transform(string: string) == ":supercalifragilisticexpialidocious,:pneumonoultramicroscopicsilicovolcanoconiosis😃a")
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            if error != nil {
                XCTFail("The regex parsing took too long, it may have gone through a catastrophic backtracking")
            }
        }
    }

}
