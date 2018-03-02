//
//  SEScene.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SEScene {
    case rooms
    case servers
    case compose
}

enum SESceneTransition {
    case none
    case pop
    case push(SEScene)
    case finish
}
