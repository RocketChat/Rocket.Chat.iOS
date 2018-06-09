//
//  NotificationViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import AudioToolbox

final class NotificationViewController: UIViewController {

    static let shared = NotificationViewController(nibName: "NotificationViewController", bundle: nil)

    @IBOutlet weak var notificationView: NotificationView!
    @IBOutlet weak var hiddenConstraint: NSLayoutConstraint!
    @IBOutlet weak var visibleConstraint: NSLayoutConstraint!

    // MARK: - Constants
    var lastTouchLocation: CGPoint?
    let animationDuration: TimeInterval = 0.3
    let notificationVisibleDuration: TimeInterval = 6.0
    let notificationContentHeight: CGFloat = 64

    let soundUrl = Bundle.main.url(forResource: "chime", withExtension: "mp3")

    var isDeviceWithNotch: Bool {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.top > 20
        } else {
            return false
        }
    }

    var notificationViewIsHidden: Bool {
        get {
            if let visibleConstraint = visibleConstraint, visibleConstraint.isActive {
                return false
            }
            return true
        }

        set {
            visibleConstraint?.isActive = !newValue
            hiddenConstraint?.isActive = newValue
            (UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.alpha = newValue || isDeviceWithNotch ? 1 : 0
        }
    }

    // MARK: - View controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notificationView.setNeedsLayout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if #available(iOS 11.0, *), isDeviceWithNotch {
            visibleConstraint.constant = notificationContentHeight +  view.safeAreaInsets.top
            view.window?.windowLevel = UIWindowLevelStatusBar - 1
        } else {
            visibleConstraint.constant = notificationContentHeight + 10
            view.window?.windowLevel = UIWindowLevelAlert
        }
    }

    // MARK: - Displaying notification
    weak var timer: Timer? {
        willSet {
            timer?.invalidate()
        }
    }

    func displayNotification(title: String, body: String, username: String) {
        guard let notificationView = notificationView else { return }

        notificationView.displayNotification(title: title, body: body, username: username)

        // Commented out until a setting is added to toggle the sound.
        // playSound()

        UIView.animate(withDuration: animationDuration) {
            self.notificationViewIsHidden = false
            self.view.layoutIfNeeded()
        }

        timer = Timer.scheduledTimer(withTimeInterval: notificationVisibleDuration, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: self?.animationDuration ?? 0.0) {
                self?.notificationViewIsHidden = true
                self?.view.layoutIfNeeded()
            }
        }
    }

    private func playSound() {
        guard let soundUrl = soundUrl else { return }
        var soundId: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
        AudioServicesPlayAlertSound(soundId)
    }

}

// MARK: - Gesture Recognizers
extension NotificationViewController {
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            NotificationManager.shared.didRespondToNotification()
            timer?.fire()
        }
    }

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let notificationView = notificationView, !notificationViewIsHidden else { return }
        switch sender.state {
        case .began:
            lastTouchLocation = sender.location(in: view)

        case .changed:
            guard let lastTouchLocation = lastTouchLocation else { return }
            let displacement = sender.location(in: view).y - lastTouchLocation.y
            let newYOffset = notificationView.frame.origin.y + displacement

            if newYOffset <= 0 {
                notificationView.frame.origin.y += displacement
                self.lastTouchLocation = sender.location(in: view)
            }

        case .ended:
            lastTouchLocation = nil
            if sender.velocity(in: view).y < -25 {
                timer?.fire()
            } else {
                view.setNeedsLayout()
                UIView.animate(withDuration: animationDuration) {
                    self.view.layoutIfNeeded()
                }
            }

        case .cancelled:
            lastTouchLocation = nil
            view.setNeedsLayout()
            UIView.animate(withDuration: animationDuration) {
                self.view.layoutIfNeeded()
            }

        default: break
        }
    }
}
