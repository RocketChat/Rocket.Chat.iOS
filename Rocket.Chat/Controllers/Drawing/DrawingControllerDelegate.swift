//
//  DrawingControllerDelegate.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 10.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol DrawingControllerDelegate: class {
    func finishedEditing(with file: FileUpload, description: String?)
}
