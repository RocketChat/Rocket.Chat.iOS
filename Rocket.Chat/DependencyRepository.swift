//
//  DependencyRepository.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 5/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct DependencyRepository: InjectionContainer {
    var socketManager = SocketManager()
    var authManager = AuthManager()
    var uploadManager = UploadManager()
}
