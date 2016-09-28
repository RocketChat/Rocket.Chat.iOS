//
//  BaseModelSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class BaseModelSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        
        Realm.execute() { (realm) in
            for obj in realm.objects(BaseModel.self) {
                realm.delete(obj)
            }
        }
    }
    
    func testBaseModelBasicInstructions() {
        Realm.execute() { (realm) in
            let object = BaseModel()
            object.identifier = "123"
            realm.add(object)
            
            let results = realm.objects(BaseModel.self)
            let first = results.first
            XCTAssert(results.count == 1)
            XCTAssert(first?.identifier == "123")
        }
    }
    
}
