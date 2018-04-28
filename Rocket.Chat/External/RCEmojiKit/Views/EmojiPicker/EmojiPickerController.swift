//
//  EmojiPickerController.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/20/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

final class EmojiPickerController: UIViewController, RCEmojiKitLocalizable {

    var emojiPicked: ((String) -> Void)?
    var customEmojis: [Emoji] = []

    private var emojiPicker: EmojiPicker! {
        didSet {
            emojiPicker.emojiPicked = { emoji in
                self.emojiPicked?(emoji)

                if self.navigationController?.topViewController == self {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true)
                }
            }

            emojiPicker.customEmojis = customEmojis
        }
    }

    override func loadView() {
        super.loadView()

        emojiPicker = EmojiPicker(frame: view.frame)
        emojiPicker.translatesAutoresizingMaskIntoConstraints = false

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

        title = localized("emojipicker.title")
    }

    override func viewWillAppear(_ animated: Bool) {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)

        // remove title from back button

        if self.navigationController?.topViewController == self {
            navigationController?.navigationBar.topItem?.title = ""
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        let center = NotificationCenter.default
        center.removeObserver(self)
        emojiPicker.endEditing(true)
    }

    override func keyboardWillShow(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }

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
                self.additionalSafeAreaInsets.bottom = convertedRect.size.height - self.view.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
            }
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }

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
