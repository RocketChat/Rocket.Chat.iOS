//
//  AttachmentFieldView.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 30/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class AttachmentFieldView: UIView {

    @IBOutlet weak var field: UILabel!
    @IBOutlet weak var value: UILabel!

    @IBOutlet weak var fieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueTopConstraint: NSLayoutConstraint!
}
