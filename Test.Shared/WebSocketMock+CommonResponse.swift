//
//  WebSocketMock+CommonResponse.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

enum WebSocketMockCommonResponse {
    case connect
    case login
    case livechatInitiate
    case livechatRegisterGuest
    case livechatSendMessage
    case livechatSendOfflineMessage
}

extension WebSocketMock {
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func use(_ commonResponse: WebSocketMockCommonResponse) {
        switch commonResponse {
        case .connect:
            use { json, send in
                guard json["msg"].stringValue == "connect" else { return }
                send(JSON(object: ["msg": "connected"]))
            }
        case .login:
            use { json, send in
                guard json["msg"].stringValue == "method" else { return }
                guard json["method"] == "login" else { return }

                // LiveChat Login
                if json["params"][0]["resume"].stringValue == "YadDPc_6IfL7YJuySZ3DkOx-LSdbCtUcsypMdHVgQhx" {
                    send(JSON(object: [
                        "fields": [
                            "profile": [
                                "guest": true,
                                "token": "6GQSl9lVbgaZjTVyJRbN"
                            ],
                            "username": "guest-1984"
                        ],
                        "collection": "users",
                        "id": "QtiyRkneTHcWYZefn",
                        "msg": "added"
                    ]))
                    send(JSON(object: [
                        "id": json["id"].stringValue,
                        "result": [
                            "id": "QtiyRkneTHcWYZefn",
                            "token": "YadDPc_6IfL7YJuySZ3DkOx-LSdbCtUcsypMdHVgQhx",
                            "tokenExpires": [
                                "$date": 2510411097067
                            ]
                        ],
                        "msg": "result"
                    ]))
                }
            }
        case .livechatInitiate:
            use { json, send in
                guard json["msg"].stringValue == "method" else { return }
                guard json["method"] == "livechat:getInitialData" else { return }
                let data: [String: Any] = [
                    "id": json["id"].stringValue,
                    "result": [
                        "transcript": false,
                        "registrationForm": true,
                        "offlineTitle": "Leave a message (Changed)",
                        "triggers": [],
                        "displayOfflineForm": true,
                        "offlineSuccessMessage": "",
                        "departments": [
                            [
                                "_id": "sGDPYaB9i47CNRLNu",
                                "numAgents": 1,
                                "enabled": true,
                                "showOnRegistration": true,
                                "_updatedAt": [
                                    "$date": 1500709708181
                                ],
                                "description": "department description",
                                "name": "1depart"
                            ],
                            [
                                "_id": "qPYPJuL6ZPTrRrzTN",
                                "numAgents": 1,
                                "enabled": true,
                                "showOnRegistration": true,
                                "_updatedAt": [
                                    "$date": 1501163003597
                                ],
                                "description": "tech support",
                                "name": "2depart"
                            ]
                        ],
                        "offlineMessage": "localhost: We are not online right now. Please leave us a message:",
                        "title": "Rocket.Local",
                        "color": "#C1272D",
                        "room": nil,
                        "offlineUnavailableMessage": "Not available offline form",
                        "enabled": true,
                        "offlineColor": "#666666",
                        "videoCall": false,
                        "language": "",
                        "transcriptMessage": "Would you like a copy of this chat emailed?",
                        "online": true,
                        "allowSwitchingDepartments": true
                        ] as [String: Any?],
                    "msg": "result"
                ]
                send(JSON(object: data))
            }
        case .livechatRegisterGuest:
            use { json, send in
                guard json["msg"].stringValue == "method" else { return }
                guard json["method"] == "livechat:registerGuest" else { return }
                let data: [String: Any] = [
                    "id": json["id"].stringValue,
                    "result": [
                        "token": "YadDPc_6IfL7YJuySZ3DkOx-LSdbCtUcsypMdHVgQhx",
                        "userId": "QtiyRkneTHcWYZefn"
                    ],
                    "msg": "result"
                ]
                send(JSON(object: data))
            }
        case .livechatSendMessage:
            use { json, send in
                guard json["msg"].stringValue == "method" else { return }
                guard json["method"] == "livechat:sendMessageLivechat" else { return }
                send(JSON(object: [
                    "id": json["id"].stringValue,
                    "result": [
                        "showConnecting": false,
                        "rid": "9dNp4a1a8IpqpNqedTI5",
                        "_id": "FF99C7A4-BBF9-4798-A03B-802FB31955B2",
                        "channels": [],
                        "token": "6GQSl9lVbgaZjTVyJRbN",
                        "alias": "Test",
                        "mentions": [],
                        "u": [
                            "_id": "QtiyRkneTHcWYZefn",
                            "username": "guest-1984",
                            "name": "Test"
                        ],
                        "ts": [
                            "$date": 1502635097560
                        ],
                        "msg": "test",
                        "_updatedAt": [
                            "$date": 1502635097567
                        ],
                        "newRoom": true
                    ],
                    "msg": "result"
                ]))
            }
        case .livechatSendOfflineMessage:
            use { json, send in
                guard json["msg"].stringValue == "method" else { return }
                guard json["method"] == "livechat:sendOfflineMessage" else { return }
                send(JSON(object: [
                    "id": json["id"].stringValue,
                    "msg": "result"
                ]))
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}
