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

        :family_mwg:

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

            👨‍👩‍👧

            ```
            Meow <- :cat:
            :dog: -> Woof

            ```
            Hello 🌎 !
            """
        )

    }

}
