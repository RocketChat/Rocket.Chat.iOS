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

    override func loadView() {
        view = EmojiPicker()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.addObserver(view)

        guard let picker = view as? EmojiPicker else {
            fatalError("View should be an instance of EmojiPicker!")
        }

        title = localized("emojipicker.title")

        picker.emojiPicked = { [unowned self] emoji in
            self.emojiPicked?(emoji)

            if self.navigationController?.topViewController == self {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }

        picker.customEmojis = customEmojis

        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        if self.navigationController?.topViewController == self {
            navigationController?.navigationBar.topItem?.title = ""
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func keyboardWillShow(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }

        guard
            let userInfo = notification.userInfo,
            let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else {
            return
        }

        let convertedRect = view.convert(rect, from: nil)

        UIView.animate(withDuration: animationDuration.doubleValue) {
            self.additionalSafeAreaInsets.bottom = convertedRect.size.height - self.view.safeAreaInsets.bottom
            self.view.layoutIfNeeded()
        }
    }

    override func keyboardWillHide(_ notification: Notification) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }

        guard
            let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
        else {
            return
        }

        UIView.animate(withDuration: animationDuration.doubleValue) {
            self.additionalSafeAreaInsets.bottom = 0
            self.view.layoutIfNeeded()
        }
    }
}
