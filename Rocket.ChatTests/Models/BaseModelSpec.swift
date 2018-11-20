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

    func testBaseModelBasicInstructions() {
        Realm.execute({ realm in
            let object = BaseModel()
            object.identifier = "123"
            realm.add(object)

            let results = realm.objects(BaseModel.self)
            let first = results.first
            XCTAssert(results.count == 1)
            XCTAssert(first?.identifier == "123")
        })
    }

    func testFindWithIdentifier() {
        let object1 = BaseModel()
        object1.identifier = "1"
        let object2 = BaseModel()
        object2.identifier = "2"
        let object3 = BaseModel()
        object1.identifier = "3"

        Realm.execute({ realm in
            realm.add(object1)
            realm.add(object2)
            realm.add(object3)
        })

        XCTAssert(BaseModel.find(withIdentifier: "2") == object2)
        XCTAssert(BaseModel.find(withIdentifier: "4") == nil)
    }

    func testDeleteWithIdentifier() {
        let object1 = BaseModel()
        object1.identifier = "obj1"
        let object2 = BaseModel()
        object2.identifier = "obj2"
        let object3 = BaseModel()
        object3.identifier = "obj3"

        Realm.execute({ realm in
            realm.add(object1)
            realm.add(object2)
            realm.add(object3)
        })

        Realm.execute({ _ in
            XCTAssert(BaseModel.delete(withIdentifier: "obj1"))
            XCTAssert(BaseModel.delete(withIdentifier: "obj3"))
            XCTAssert(BaseModel.delete(withIdentifier: "obj3") == false)
        })

        XCTAssert(Realm.current?.objects(BaseModel.self).count == 1)
        XCTAssert(Realm.current?.objects(BaseModel.self).first == object2)
    }
}
