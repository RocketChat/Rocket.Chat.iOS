//
//  SEComposeImageView.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct SEComposeImageViewModel {
    var titleTextFieldPlaceHhlder {
        return localized("compose.image.title.placeholder")
    }

    var descriptionTextFieldPlaceholder {
        return localized("compose.image.description.placeholder")
    }
}

class SEComposeImageViewController: SEViewController {
    @IBOutlet weak var titleTextField: UITextField! {
        didSet {

        }
    }


    @IBOutlet weak var descriptionTextField: UITextField!


}
