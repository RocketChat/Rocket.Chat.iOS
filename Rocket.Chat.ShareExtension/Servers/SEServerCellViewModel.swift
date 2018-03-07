//
//  SEServerCellViewModel.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct SEServerCellViewModel: SECell {
    let iconUrl: String
    let name: String
    let host: String
    let selected: Bool
}
