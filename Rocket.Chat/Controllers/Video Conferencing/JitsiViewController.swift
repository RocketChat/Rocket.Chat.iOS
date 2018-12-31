//
//  JitsiViewController.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 21/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import JitsiMeet

final class JitsiViewController: UIViewController {

    let viewModel = JitsiViewModel()
    let timer = Timer()

    @IBOutlet weak var jitsiMeetView: JitsiMeetView?

    deinit {
        timer.invalidate()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsManager.log(event: .jitsiVideoCall(
            subscriptionType: viewModel.analyticsSubscriptionType,
            server: viewModel.analyticsServerURL
        ))

        // Jitsi Update Call needs to be called every 10 seconds to make sure
        // call is not ended and is available to web users.
        updateJitsiTimeout()
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.updateJitsiTimeout()
        }

        jitsiMeetView?.delegate = self
        jitsiMeetView?.loadURLObject([
            "config": [
                "startWithAudioMuted": false,
                "startWithVideoMuted": true
            ],
            "context": [
                "user": [
                    "name": viewModel.userDisplayName,
                    "avatar": viewModel.userAvatar
                ],
                "iss": "rocketchat-ios"
            ],
            "url": viewModel.videoCallURL
        ])
    }

    func updateJitsiTimeout() {
        guard let subscription = self.viewModel.subscription else { return }
        SubscriptionManager.updateJitsiTimeout(rid: subscription.rid)
    }

    func close() {
        timer.invalidate()

        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil

        dismiss(animated: true, completion: nil)
    }

}

// MARK: JitsiMeetViewDelegate

extension JitsiViewController: JitsiMeetViewDelegate {

    func onJitsiMeetViewDelegateEvent(name: String, data: [AnyHashable: Any]) {
        Log.debug("[\(#file):\(#line)] JitsiMeetViewDelegate \(name) \(data)")
    }

    func conferenceFailed(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_FAILED", data: data)
        Log.debug("conference Failed log is : \(data)")
    }

    func conferenceJoined(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_JOINED", data: data)
        Log.debug("conference Joined log is : \(data)")
    }

    func conferenceLeft(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_LEFT", data: data)
        Log.debug("conference Left log is : \(data)")
        close()
    }

    func conferenceWillJoin(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_JOIN", data: data)
        Log.debug("conference Join log is : \(data)")
    }

    func conferenceWillLeave(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "CONFERENCE_WILL_LEAVE", data: data)
        Log.debug("conference Leave log is : \(data)")
        close()
    }

    func loadConfigError(_ data: [AnyHashable: Any]) {
        onJitsiMeetViewDelegateEvent(name: "LOAD_CONFIG_ERROR", data: data)
        Log.debug("conference Error log is : \(data)")
    }

}
