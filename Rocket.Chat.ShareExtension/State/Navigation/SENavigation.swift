//
//  SENavigation.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

struct SENavigation {
    var scenes: [SEScene] = []
    var sceneTransition: SESceneTransition = .none

    mutating func makeTransition(_ transition: SESceneTransition) {
        sceneTransition = transition
        switch transition {
        case .pop:
            _ = scenes.popLast()
        case .push(let scene):
            scenes.append(scene)
        case .finish:
            break
        case .none:
            break
        }
    }
}
