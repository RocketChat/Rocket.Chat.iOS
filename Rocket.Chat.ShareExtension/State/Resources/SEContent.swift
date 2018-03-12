//
//  SEContent.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEFile {
    let name: String
    let mimeType: String
    let data: Data
}

enum SEContent {
    case text(String)
    case file(SEFile)
}
