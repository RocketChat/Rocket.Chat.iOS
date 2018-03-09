//
//  SEComposeImageView.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

struct SEComposeImageViewModel {
    let image: UIImage

    var titleTextFieldPlaceholder: String {
        return localized("compose.image.title.placeholder")
    }

    var descriptionTextFieldPlaceholder: String {
        return localized("compose.image.description.placeholder")
    }
}

extension SEComposeImageViewModel {
    init(state: SEState) {
        if case let .image(image) = state.content {
            self.image = image
        } else {
            self.image = UIImage()
        }
    }
}

class SEComposeImageViewController: SEViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    var viewModel = SEComposeImageViewModel(image: UIImage()) {
        didSet {
            titleTextField.placeholder = viewModel.titleTextFieldPlaceholder
            descriptionTextField.placeholder = viewModel.descriptionTextFieldPlaceholder
            imageView.image = viewModel.image
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func stateUpdated(_ state: SEState) {
        viewModel = SEComposeImageViewModel(state: state)
    }
}
