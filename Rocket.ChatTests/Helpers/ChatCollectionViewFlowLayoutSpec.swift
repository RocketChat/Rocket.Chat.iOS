//
//  ChatCollectionViewFlowLayoutSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/30/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ChatCollectionViewFlowLayoutSpec: XCTestCase {
    func testTargetContentOffset() {
        let layout = ChatCollectionViewFlowLayout()
        let offset = layout.targetContentOffset(forProposedContentOffset: CGPoint(x: 50.0, y: 50.0))

        XCTAssertEqual(offset, CGPoint(x: 50.0, y: 50.0))

        layout.heightOfInsertedItems = 50.0

        let offset2 = layout.targetContentOffset(forProposedContentOffset: CGPoint(x: 50.0, y: 50.0))

        XCTAssertEqual(offset2, CGPoint(x: 50.0, y: 100.0))
    }

    func testTargetContentOffsetWithVelocity() {
        let layout = ChatCollectionViewFlowLayout()
        let offset = layout.targetContentOffset(
            forProposedContentOffset: CGPoint(x: 50.0, y: 50.0),
            withScrollingVelocity: CGPoint(x: 50.0, y: 50.0)
        )

        XCTAssertEqual(offset, CGPoint(x: 50.0, y: 50.0))

        layout.heightOfInsertedItems = 50.0

        let offset2 = layout.targetContentOffset(
            forProposedContentOffset: CGPoint(x: 50.0, y: 50.0),
            withScrollingVelocity: CGPoint(x: 50.0, y: 50.0)
        )

        XCTAssertEqual(offset2, CGPoint(x: 50.0, y: 100.0))
    }
}
