//
//  SESceneTransition.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

enum SESceneTransition {
    case none
    case pop
    case push(SEScene)
    case finish
}
