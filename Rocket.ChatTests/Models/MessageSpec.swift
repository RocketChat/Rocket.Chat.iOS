//
//  MessageSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

class MessageSpec: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Realm.execute() { (realm) in
            for obj in realm.objects(User) {
                realm.delete(obj)
            }
            
            for obj in realm.objects(Auth) {
                realm.delete(obj)
            }
            
            for obj in realm.objects(Message) {
                realm.delete(obj)
            }
            
            for obj in realm.objects(Subscription) {
                realm.delete(obj)
            }
        }
    }
    
    func testSubscriptionObject() {
        let auth = Auth()
        auth.serverURL = "http://foo.bar.baz"
        
        let subscription = Subscription()
        subscription.auth = auth
        subscription.identifier = "123"
        
        let user = User()
        user.identifier = "123"
        
        let message = Message()
        message.identifier = "123"
        message.text = "text"
        message.user = user
        message.subscription = subscription
        
        Realm.execute() { (realm) in
            realm.add(message)
            
            let results = realm.objects(Message)
            let first = results.first
            XCTAssert(results.count == 1, "Message object was created with success")
            XCTAssert(first?.identifier == "123", "Message object was created with success")
            XCTAssert(subscription.messages.first?.identifier == first?.identifier, "Message relationship with Subscription is OK")
        }
    }
    
    func testMessageObjectFromJSON() {
        let object = JSON([
            "_id": "123",
            "rid": "123",
            "msg": "Foo Bar Baz",
            "ts": ["$date": 1234567891011],
            "_updatedAt": ["$date": 1234567891011]
        ])
        
        let message = Message(object: object)

        Realm.execute() { (realm) in
            realm.add(message)
            
            let results = realm.objects(Message)
            let first = results.first
            XCTAssert(results.count == 1, "Message object was created with success")
            XCTAssert(first?.identifier == "123", "Message object was created with success")
        }
    }
    
}