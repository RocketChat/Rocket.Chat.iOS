//
//  SEViewController.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

enum SEError: Error {
    case noServers
    case canceled
}

class SEViewController: UIViewController, SEStoreSubscriber {

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        activityIndicator.layer.cornerRadius = 10
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        return activityIndicator
    }()

    override var shouldAutorotate: Bool {
        return false
    }

    var avoidsKeyboard: Bool = true {
        didSet {
            if avoidsKeyboard {
                startAvoidingKeyboard()
            } else {
                stopAvoidingKeyboard()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
        startAvoidingKeyboard()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        store.unsubscribe(self)
        stopAvoidingKeyboard()
    }

    func stateUpdated(_ state: SEState) {

    }

    func cancelShareExtension() {
        self.extensionContext?.cancelRequest(withError: SEError.canceled)
    }

    // MARK: Avoid Keyboard

    func startAvoidingKeyboard() {
        guard avoidsKeyboard else { return }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onKeyboardFrameWillChange(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )

        additionalSafeAreaInsets.bottom = 0
    }

    func stopAvoidingKeyboard() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc func onKeyboardFrameWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)

        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)

        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            let keyboardDisappeared = keyboardFrameInView == .zero
            self.additionalSafeAreaInsets.bottom = keyboardDisappeared ? 0.0 : intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension SEViewController {
    static func fromStoryboard<T: SEViewController>() -> T {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        guard let viewController = storyboard.instantiateViewController(withIdentifier: "\(self)") as? T else {
            fatalError("ViewController not found in Main storyboard: \(self)")
        }

        return viewController
    }
}
