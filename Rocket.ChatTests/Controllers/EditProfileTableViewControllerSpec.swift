//
//  EditProfileTableViewControllerSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 26/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class EditProfileTableViewControllerSpec: XCTestCase {

    let editProfile = EditProfileTableViewController()

    func test() {
        let jsonString = """
        {
            "_id": "aobEdbYhXfu5hkeqG",
            "name": "Example User",
            "emails": [
                {
                    "address": "example@example.com",
                    "verified": true
                }
            ],
            "status": "offline",
            "statusConnection": "offline",
            "username": "example",
            "utcOffset": 0,
            "active": true,
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = MeResult(raw: json)
    }

}
