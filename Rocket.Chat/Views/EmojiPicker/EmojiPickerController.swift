//
//  EmojiPickerController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class EmojiPickerController: UIViewController {

    var emojiPicked: ((String) -> Void)?
    private var emojiPicker: EmojiPicker! {
        didSet {
            emojiPicker.emojiPicked = { emoji in
                self.emojiPicked?(emoji)
                self.dismiss(animated: true)
            }
        }
    }

    override func loadView() {
        super.loadView()

        emojiPicker = EmojiPicker(frame: view.frame)
        view.addSubview(emojiPicker)

        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": emojiPicker]
            )
        )
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": emojiPicker]
            )
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        emojiPicker.searchBar.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        let center = NotificationCenter.default
        center.removeObserver(self)
        emojiPicker.searchBar.resignFirstResponder()
    }

    override func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let rect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
        else {
            return
        }

        let convertedRect = view.convert(rect, from: nil)

        UIView.animate(withDuration: animationDuration.doubleValue) {
            if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.bottom = convertedRect.size.height
                self.view.layoutIfNeeded()
            }
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
        else {
            return
        }

        UIView.animate(withDuration: animationDuration.doubleValue) {
            if #available(iOS 11, *) {
                self.additionalSafeAreaInsets.bottom = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}
