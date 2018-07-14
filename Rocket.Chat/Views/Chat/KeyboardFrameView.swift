//
//  KeyboardFrameView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SlackTextViewController

protocol KeyboardFrameViewDelegate: class {
    func keyboardDidChangeFrame(frame: CGRect?)
    var keyboardProxyView: UIView? { get }
}

final class KeyboardFrameView: UIView {
    weak var delegate: KeyboardFrameViewDelegate?
    weak var keyboardProxyView: UIView?

    init(withDelegate delegate: KeyboardFrameViewDelegate) {
        super.init(frame: CGRect.zero)
        self.delegate = delegate
        registerForNotification()
    }

    private func registerForNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidChangeFrameNotificationReceived),
            name: Notification.Name.UIKeyboardDidChangeFrame,
            object: nil
        )
    }

    func updateFrame() {
        if self.frame.height > 0 || keyboardProxyView == nil || keyboardProxyView?.frame.height == 0 {
            delegate?.keyboardDidChangeFrame(frame: self.frame)
        }
    }

    @objc private func keyboardDidChangeFrameNotificationReceived() {
        delegate?.keyboardDidChangeFrame(frame: nil)

        if delegate?.keyboardProxyView != keyboardProxyView {
            keyboardProxyView = delegate?.keyboardProxyView
            attachToKeyboardProxyView()
        }
    }

    private func attachToKeyboardProxyView() {
        guard let keyboardProxyView = keyboardProxyView else { return }

        keyboardProxyView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: keyboardProxyView.topAnchor),
            self.leftAnchor.constraint(equalTo: keyboardProxyView.leftAnchor),
            self.rightAnchor.constraint(equalTo: keyboardProxyView.rightAnchor),
            self.bottomAnchor.constraint(equalTo: keyboardProxyView.superview?.bottomAnchor ?? keyboardProxyView.bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
