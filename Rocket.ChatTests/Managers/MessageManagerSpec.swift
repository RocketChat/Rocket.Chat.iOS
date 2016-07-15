//
//  MessageManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class MessageManagerSpec: XCTestCase {
    
    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        // Clear all the Message objects in Realm
        try! realm.write {
            for obj in realm.objects(Message.self) {
                realm.delete(obj)
            }
            
            for obj in realm.objects(Subscription.self) {
                realm.delete(obj)
            }
        }
    }

}


// MARK: Realm Data Tests

extension MessageManagerSpec {
    
    func testAllMessagesReturnsOnlyRelatedToSubscription() {
        let subscription1 = Subscription()
        subscription1.identifier = "subs1"
    
        let message1 = Message()
        message1.identifier = "msg1"
        message1.subscription = subscription1
        
        let subscription2 = Subscription()
        subscription2.identifier = "subs2"
    
        let message2 = Message()
        message2.identifier = "msg2"
        message2.subscription = subscription2
        
        try! realm.write {
            realm.add([subscription1, subscription2, message1, message2])
        }
        
        let messages1 = MessageManager.allMessages(subscription1)
        let messages2 = MessageManager.allMessages(subscription2)
        
        XCTAssert(messages1.count == 1, "allMessages() will return all messages related to the subscription")
        XCTAssert(messages2.count == 1, "allMessages() will return all messages related to the subscription")
        XCTAssert(messages1[0].identifier == message1.identifier, "allMessages() will return just messages related to the subscription")
        XCTAssert(messages2[0].identifier == message2.identifier, "allMessages() will return just messages related to the subscription")
    }
    
    func testAllMessagesReturnsMessagesOrderedByDate() {
        let subscription = Subscription()
        subscription.identifier = "subscription"

        let message1 = Message()
        message1.identifier = "msg1"
        message1.createdAt = NSDate(timeIntervalSinceNow: -100)
        message1.subscription = subscription
        
        let message2 = Message()
        message2.identifier = "msg2"
        message2.createdAt = NSDate(timeIntervalSinceNow: 0)
        message2.subscription = subscription
        
        try! realm.write {
            realm.add([subscription, message1, message2])
        }
        
        let messages = MessageManager.allMessages(subscription)
        XCTAssert(messages.count == 2, "allMessages() will return all messages related to the subscription")
        XCTAssert(messages[0].identifier == message1.identifier, "allMessages() will return messages ordered by date")
        XCTAssert(messages[1].identifier == message2.identifier, "allMessages() will return messages ordered by date")
    }
    
}